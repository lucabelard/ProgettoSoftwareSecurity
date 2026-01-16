const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

contract("BNCalcolatoreOnChain - Test su Besu", (accounts) => {
    let contract;
    const [admin, sensore, mittente, corriere] = accounts;

    beforeEach(async () => {
        contract = await BNCalcolatoreOnChain.deployed();
    });

    describe("1. Deploy e Inizializzazione", () => {
        it("Contratto dovrebbe essere deployato", async () => {
            assert.ok(contract.address, "Contratto non deployato");
        });

        it("Admin dovrebbe avere ruolo DEFAULT_ADMIN_ROLE", async () => {
            const DEFAULT_ADMIN_ROLE = await contract.DEFAULT_ADMIN_ROLE();
            const hasRole = await contract.hasRole(DEFAULT_ADMIN_ROLE, admin);
            assert.equal(hasRole, true, "Admin non ha DEFAULT_ADMIN_ROLE");
        });

        it("SOGLIA_PROBABILITA dovrebbe essere 95", async () => {
            const soglia = await contract.SOGLIA_PROBABILITA();
            assert.equal(soglia.toString(), "95", "Soglia errata");
        });
    });

    describe("2. Configurazione Bayesian Network", () => {
        it("Admin dovrebbe poter impostare probabilità a priori", async () => {
            await contract.impostaProbabilitaAPriori(99, 99, { from: admin });

            const pF1T = await contract.p_F1_T();
            const pF2T = await contract.p_F2_T();

            assert.equal(pF1T.toString(), "99", "P(F1=T) non impostata");
            assert.equal(pF2T.toString(), "99", "P(F2=T) non impostata");
        });

        it("Admin dovrebbe poter impostare CPT per E1", async () => {
            const cpt = {
                p_FF: 5,
                p_FT: 30,
                p_TF: 50,
                p_TT: 99
            };

            await contract.impostaCPT(1, cpt, { from: admin });

            const cptE1 = await contract.cpt_E1();
            assert.equal(cptE1.p_TT.toString(), "99", "CPT E1 non impostata");
        });

        it("Non-admin NON dovrebbe poter impostare probabilità", async () => {
            try {
                await contract.impostaProbabilitaAPriori(80, 80, { from: mittente });
                assert.fail("Dovrebbe fallire");
            } catch (error) {
                assert.include(error.message, "revert", "Errore atteso");
            }
        });
    });

    describe("3. Gestione Spedizioni", () => {
        it("Mittente dovrebbe poter creare spedizione", async () => {
            const importo = web3.utils.toWei("0.001", "ether");

            const tx = await contract.creaSpedizione(corriere, {
                from: admin, // admin ha anche RUOLO_MITTENTE
                value: importo
            });

            assert.ok(tx.logs.length > 0, "Nessun evento emesso");

            const event = tx.logs.find(log => log.event === "SpedizioneCreata");
            assert.ok(event, "Evento SpedizioneCreata non emesso");

            const idSpedizione = event.args.id.toString();
            assert.equal(idSpedizione, "1", "ID spedizione errato");
        });

        it("Spedizione dovrebbe avere dati corretti", async () => {
            const spedizione = await contract.spedizioni(1);

            assert.equal(spedizione.mittente, admin, "Mittente errato");
            assert.equal(spedizione.corriere, corriere, "Corriere errato");
            assert.equal(spedizione.stato.toString(), "0", "Stato dovrebbe essere InAttesa");
        });

        it("NON dovrebbe permettere spedizione con 0 ETH", async () => {
            try {
                await contract.creaSpedizione(corriere, {
                    from: admin,
                    value: 0
                });
                assert.fail("Dovrebbe fallire");
            } catch (error) {
                assert.include(error.message, "revert", "Errore atteso");
            }
        });
    });

    describe("4. Sistema Evidenze", () => {
        beforeEach(async () => {
            // Crea spedizione per test
            const importo = web3.utils.toWei("0.001", "ether");
            await contract.creaSpedizione(corriere, {
                from: admin,
                value: importo
            });
        });

        it("Sensore dovrebbe poter inviare evidenza E1", async () => {
            await contract.inviaEvidenza(2, 1, true, { from: admin }); // admin ha RUOLO_SENSORE

            const spedizione = await contract.spedizioni(2);
            assert.equal(spedizione.evidenze.E1_ricevuta, true, "E1 non ricevuta");
            assert.equal(spedizione.evidenze.E1_valore, true, "Valore E1 errato");
        });

        it("Dovrebbe permettere invio di tutte le evidenze", async () => {
            await contract.inviaEvidenza(2, 1, true, { from: admin });
            await contract.inviaEvidenza(2, 2, true, { from: admin });
            await contract.inviaEvidenza(2, 3, false, { from: admin });
            await contract.inviaEvidenza(2, 4, false, { from: admin });
            await contract.inviaEvidenza(2, 5, true, { from: admin });

            const spedizione = await contract.spedizioni(2);
            assert.equal(spedizione.evidenze.E1_ricevuta, true, "E1 non ricevuta");
            assert.equal(spedizione.evidenze.E5_ricevuta, true, "E5 non ricevuta");
        });

        it("NON dovrebbe permettere ID evidenza invalido", async () => {
            try {
                await contract.inviaEvidenza(2, 6, true, { from: admin });
                assert.fail("Dovrebbe fallire");
            } catch (error) {
                assert.include(error.message, "revert", "Errore atteso");
            }
        });
    });

    describe("5. Validazione e Pagamento", () => {
        let idSpedizione;

        beforeEach(async () => {
            // Setup completo: probabilità + CPT + spedizione + evidenze
            await contract.impostaProbabilitaAPriori(99, 99, { from: admin });

            const cptPositiva = { p_FF: 5, p_FT: 30, p_TF: 50, p_TT: 99 };
            const cptNegativa = { p_FF: 95, p_FT: 70, p_TF: 50, p_TT: 1 };

            await contract.impostaCPT(1, cptPositiva, { from: admin }); // E1 positiva
            await contract.impostaCPT(2, cptPositiva, { from: admin }); // E2 positiva
            await contract.impostaCPT(3, cptNegativa, { from: admin }); // E3 negativa
            await contract.impostaCPT(4, cptNegativa, { from: admin }); // E4 negativa
            await contract.impostaCPT(5, cptPositiva, { from: admin }); // E5 positiva

            const importo = web3.utils.toWei("0.001", "ether");
            const tx = await contract.creaSpedizione(corriere, {
                from: admin,
                value: importo
            });

            idSpedizione = tx.logs[0].args.id.toString();

            // Invia evidenze conformi
            await contract.inviaEvidenza(idSpedizione, 1, true, { from: admin });
            await contract.inviaEvidenza(idSpedizione, 2, true, { from: admin });
            await contract.inviaEvidenza(idSpedizione, 3, false, { from: admin });
            await contract.inviaEvidenza(idSpedizione, 4, false, { from: admin });
            await contract.inviaEvidenza(idSpedizione, 5, true, { from: admin });
        });

        it("Corriere dovrebbe ricevere pagamento con evidenze conformi", async () => {
            const tx = await contract.validaEPaga(idSpedizione, { from: corriere });

            // Verifica che evento SpedizionePagata sia stato emesso
            const event = tx.logs.find(log => log.event === "SpedizionePagata");
            assert.ok(event, "Evento SpedizionePagata non emesso");
            assert.equal(event.args.id.toString(), idSpedizione, "ID spedizione errato");
            assert.equal(event.args.corriere, corriere, "Corriere errato");
            assert.ok(event.args.importo > 0, "Importo pagamento deve essere > 0");
        });

        it("Stato spedizione dovrebbe diventare Pagata", async () => {
            await contract.validaEPaga(idSpedizione, { from: corriere });

            const spedizione = await contract.spedizioni(idSpedizione);
            assert.equal(spedizione.stato.toString(), "1", "Stato non aggiornato a Pagata");
        });

        it("NON dovrebbe permettere validazione senza tutte le evidenze", async () => {
            const importo = web3.utils.toWei("0.001", "ether");
            const tx = await contract.creaSpedizione(corriere, { from: admin, value: importo });
            const newId = tx.logs[0].args.id.toString();

            // Invia solo 3 evidenze su 5
            await contract.inviaEvidenza(newId, 1, true, { from: admin });
            await contract.inviaEvidenza(newId, 2, true, { from: admin });
            await contract.inviaEvidenza(newId, 3, false, { from: admin });

            try {
                await contract.validaEPaga(newId, { from: corriere });
                assert.fail("Dovrebbe fallire");
            } catch (error) {
                assert.include(error.message, "revert", "Errore atteso");
            }
        });

        it("NON dovrebbe permettere validazione da account non-corriere", async () => {
            try {
                await contract.validaEPaga(idSpedizione, { from: mittente });
                assert.fail("Dovrebbe fallire");
            } catch (error) {
                assert.include(error.message, "revert", "Errore atteso");
            }
        });
    });

    describe("6. Test Sicurezza", () => {
        it("NON dovrebbe permettere doppio pagamento", async () => {
            // Setup spedizione
            await contract.impostaProbabilitaAPriori(99, 99, { from: admin });
            const cptPositiva = { p_FF: 5, p_FT: 30, p_TF: 50, p_TT: 99 };
            const cptNegativa = { p_FF: 95, p_FT: 70, p_TF: 50, p_TT: 1 };

            await contract.impostaCPT(1, cptPositiva, { from: admin });
            await contract.impostaCPT(2, cptPositiva, { from: admin });
            await contract.impostaCPT(3, cptNegativa, { from: admin });
            await contract.impostaCPT(4, cptNegativa, { from: admin });
            await contract.impostaCPT(5, cptPositiva, { from: admin });

            const importo = web3.utils.toWei("0.001", "ether");
            const tx = await contract.creaSpedizione(corriere, { from: admin, value: importo });
            const id = tx.logs[0].args.id.toString();

            // Evidenze conformi
            await contract.inviaEvidenza(id, 1, true, { from: admin });
            await contract.inviaEvidenza(id, 2, true, { from: admin });
            await contract.inviaEvidenza(id, 3, false, { from: admin });
            await contract.inviaEvidenza(id, 4, false, { from: admin });
            await contract.inviaEvidenza(id, 5, true, { from: admin });

            // Primo pagamento
            await contract.validaEPaga(id, { from: corriere });

            // Secondo tentativo
            try {
                await contract.validaEPaga(id, { from: corriere });
                assert.fail("Dovrebbe fallire");
            } catch (error) {
                assert.include(error.message, "revert", "Errore atteso");
            }
        });
    });
});
