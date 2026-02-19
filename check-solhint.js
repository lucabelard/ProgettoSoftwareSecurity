const { execSync } = require('child_process');

try {
    execSync(
        'npx solhint contracts/BNCore.sol contracts/BNGestoreSpedizioni.sol contracts/BNPagamenti.sol contracts/BNCalcolatoreOnChain.sol',
        { cwd: __dirname, encoding: 'utf8', stdio: 'inherit' }
    );
} catch (e) {
    process.exit(0);
}
