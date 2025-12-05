// Importa il nuovo contratto
const BNCalcolatoreOnChain = artifacts.require("BNCalcolatoreOnChain");

module.exports = async function (deployer, network, accounts) {

  // Definiamo gli attori (come nei test)
  const admin = accounts[0]; // Chi fa il deploy
  const indirizzoOracolo = accounts[0]; // Per semplicità, chi deploya è anche l'Oracolo
  const indirizzoSensore = accounts[1]; // Un account che simula tutti i sensori
  const indirizzoMittente = accounts[2];

  console.log("----------------------------------------------------");
  console.log("Deploying BNCalcolatoreOnChain...");
  console.log("----------------------------------------------------");

  // 1. DEPLOY DEL CONTRATTO
  // Il costruttore ora assegna i ruoli a 'admin' (accounts[0])
  await deployer.deploy(BNCalcolatoreOnChain, { from: admin });
  const instance = await BNCalcolatoreOnChain.deployed();
  console.log("Contratto deployato a:", instance.address);

  // Assegniamo i ruoli agli altri account per i test
  await instance.grantRole(await instance.RUOLO_SENSORE(), indirizzoSensore, { from: admin });
  await instance.grantRole(await instance.RUOLO_MITTENTE(), indirizzoMittente, { from: admin });
  console.log(`Ruolo SENSORE assegnato a: ${indirizzoSensore}`);
  console.log(`Ruolo MITTENTE assegnato a: ${indirizzoMittente}`);


  // --- 2. SETUP DELLE PROBABILITÀ (Come da PDF, pag. 17-18) ---

  // Useremo valori (0-100) per rappresentare le probabilità (0.0 - 1.0)
  const PRECISIONE = 100;

  console.log("Inizio setup probabilità (CPT)...");

  // 2a. Imposta probabilità a priori: P(F1=T)=99%, P(F2=T)=99%
  await instance.impostaProbabilitaAPriori(99, 99, { from: indirizzoOracolo });
  console.log("Probabilità a priori impostate (P(F1)=99, P(F2)=99)");

  // 2b. Imposta le CPT (Tabelle di Probabilità Condizionale)
  // Per evidenze POSITIVE (T=good): E1, E2, E5
  const cptPositiva = { p_FF: 5, p_FT: 30, p_TF: 50, p_TT: 99 };

  // Per evidenze NEGATIVE (F=good): E3, E4
  // Invertiamo la logica: quando tutto è OK (TT), E=F con prob alta
  const cptNegativa = { p_FF: 95, p_FT: 70, p_TF: 50, p_TT: 1 };

  // E1 (Temperatura): T=good
  await instance.impostaCPT(1, cptPositiva, { from: indirizzoOracolo });

  // E2 (Sigillo): T=good
  await instance.impostaCPT(2, cptPositiva, { from: indirizzoOracolo });

  // E3 (Shock): F=good (no shock)
  await instance.impostaCPT(3, cptNegativa, { from: indirizzoOracolo });

  // E4 (Luce): F=good (no apertura)
  await instance.impostaCPT(4, cptNegativa, { from: indirizzoOracolo });

  // E5 (Scan): T=good
  await instance.impostaCPT(5, cptPositiva, { from: indirizzoOracolo });

  console.log("Setup delle CPT per E1-E5 completato.");
  console.log("----------------------------------------------------");
};
// Importa il file .json del contratto compilato (artifact)
/*
const OracoloCatenaFreddo = artifacts.require("OracoloCatenaFreddo");

module.exports = async function (deployer, network, accounts) {
  
  // Scegliamo quale account di Ganache useremo per simulare
  // il nostro Oracolo Off-chain.
  // NON usiamo 'accounts[0]' perché è quello che fa il deploy (msg.sender)
  // e ha già il ruolo di ADMIN.
  // Usiamo 'accounts[1]' per separare i privilegi.
  const indirizzoOracoloOffChain = accounts[1];

  console.log("----------------------------------------------------");
  console.log("Deploying OracoloCatenaFreddo...");
  console.log("Account dell'Oracolo Off-chain (RUOLO_ORACOLO):", indirizzoOracoloOffChain);
  console.log("----------------------------------------------------");

  // Fai il deploy del contratto.
  // Passiamo 'indirizzoOracoloOffChain' al costruttore del contratto,
  // che lo userà per assegnare il RUOLO_ORACOLO.
  await deployer.deploy(OracoloCatenaFreddo, indirizzoOracoloOffChain);

  // Opzionale: stampa l'indirizzo del contratto deployato
  const contrattoDeployato = await OracoloCatenaFreddo.deployed();
  console.log("Contratto OracoloCatenaFreddo deployato a:", contrattoDeployato.address);
};
*/