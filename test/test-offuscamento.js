/**
 * Test per verificare modifiche di offuscamento
 * - CPT Private con access control
 * - Hashing dettagli spedizioni
 */

const BNCore = artifacts.require("BNCore");
const BNGestoreSpedizioni = artifacts.require("BNGestoreSpedizioni");
const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

contract("Offuscamento - CPT Private", accounts => {
    let contract;
    const admin = accounts[0];
    const oracolo = accounts[0];
    const nonAutorizzato = accounts[1];

    before(async () => {
        contract = await BNCalcolatoreOnChain.deployed();
        // Admin ha già DEFAULT_ADMIN_ROLE di default, nessun grant necessario
    });

    it("✅ Admin può leggere CPT private", async () => {
        // Setup CPT
        const cpt = {
            p_FF: 10,
            p_FT: 30,
            p_TF: 70,
            p_TT: 99
        };
        await contract.impostaCPT(1, cpt, { from: oracolo });

        // Admin legge CPT_E1
        const result = await contract.getCPT_E1({ from: admin });

        assert.equal(result.p_TT.toString(), "99", "CPT letto correttamente da admin");
        assert.equal(result.p_FF.toString(), "10", "Valori CPT corretti");
    });

    it("❌ Non autorizzato NON può leggere CPT", async () => {
        try {
            await contract.getCPT_E1({ from: nonAutorizzato });
            assert.fail("Dovrebbe revertare per utente non autorizzato");
        } catch (error) {
            assert.include(error.message.toLowerCase(), "revert", "Errore di access control corretto");
        }
    });

    it("✅ Test tutti i 5 getter CPT", async () => {
        const cpt1 = await contract.getCPT_E1({ from: admin });
        const cpt2 = await contract.getCPT_E2({ from: admin });
        const cpt3 = await contract.getCPT_E3({ from: admin });
        const cpt4 = await contract.getCPT_E4({ from: admin });
        const cpt5 = await contract.getCPT_E5({ from: admin });

        // Dovrebbero tutti ritornare senza errori
        assert.ok(cpt1, "CPT_E1 leggibile");
        assert.ok(cpt2, "CPT_E2 leggibile");
        assert.ok(cpt3, "CPT_E3 leggibile");
        assert.ok(cpt4, "CPT_E4 leggibile");
        assert.ok(cpt5, "CPT_E5 leggibile");
    });
});

contract("Offuscamento - Hashing Dettagli", accounts => {
    let contract;
    const mittente = accounts[0];
    const corriere = accounts[1];

    before(async () => {
        contract = await BNCalcolatoreOnChain.deployed();

        // Grant ruolo mittente
        const RUOLO_MITTENTE = web3.utils.keccak256("RUOLO_MITTENTE");
        await contract.grantRole(RUOLO_MITTENTE, mittente, { from: accounts[0] });
    });

    it("✅ Crea spedizione con hash dei dettagli", async () => {
        // Dettagli sensibili (off-chain)
        const dettagliSensibili = JSON.stringify({
            farmaco: "Vaccino COVID-19",
            lotto: "ABC123",
            destinazione: "Ospedale Milano",
            paziente: "Confidenziale"
        });

        // Calcola hash
        const hashedDetails = web3.utils.keccak256(dettagliSensibili);

        // Crea spedizione con hash
        const receipt = await contract.creaSpedizioneConHash(
            corriere,
            hashedDetails,
            {
                from: mittente,
                value: web3.utils.toWei('0.1', 'ether')
            }
        );

        // Verifica evento
        const event = receipt.logs.find(log => log.event === 'DettagliHashatiSalvati');
        assert.ok(event, "Evento DettagliHashatiSalvati emesso");
        assert.equal(event.args.hashedDetails, hashedDetails, "Hash salvato correttamente");
    });

    it("✅ Verifica dettagli tramite hash", async () => {
        // Dettagli originali
        const dettagliOriginali = JSON.stringify({
            farmaco: "Vaccino COVID-19",
            lotto: "ABC123",
            destinazione: "Ospedale Milano",
            paziente: "Confidenziale"
        });

        const hashedDetails = web3.utils.keccak256(dettagliOriginali);

        // Crea spedizione
        await contract.creaSpedizioneConHash(
            corriere,
            hashedDetails,
            {
                from: mittente,
                value: web3.utils.toWei('0.1', 'ether')
            }
        );

        // L'ID sarà 1 o incrementale
        const spedizioneId = await contract._contatoreIdSpedizione();

        // Verifica con dettagli corretti
        const isValid = await contract.verificaDettagli(spedizioneId, dettagliOriginali);
        assert.equal(isValid, true, "Dettagli corretti verificati");

        // Verifica con dettagli errati
        const dettagliErrati = "Dati sbagliati";
        const isInvalid = await contract.verificaDettagli(spedizioneId, dettagliErrati);
        assert.equal(isInvalid, false, "Dettagli errati non verificati");
    });

    it("❌ Non accetta hash vuoto", async () => {
        try {
            await contract.creaSpedizioneConHash(
                corriere,
                "0x0000000000000000000000000000000000000000000000000000000000000000",
                {
                    from: mittente,
                    value: web3.utils.toWei('0.1', 'ether')
                }
            );
            assert.fail("Dovrebbe revertare con hash vuoto");
        } catch (error) {
            assert.include(error.message.toLowerCase(), "revert", "Errore per hash vuoto");
        }
    });
});
