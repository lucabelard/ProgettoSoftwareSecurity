@echo off
echo =============================================
echo 🚀 Running Performance Test for BN_Simple
echo =============================================
call truffle test test\performance\simple-performance-test.js --network besu --grep "BN_Simple"
if errorlevel 1 echo ❌ BN_Simple Failed

echo =============================================
echo 🚀 Running Performance Test for BN_Medium
echo =============================================
call truffle test test\performance\simple-performance-test.js --network besu --grep "BN_Medium"
if errorlevel 1 echo ❌ BN_Medium Failed

echo =============================================
echo 🚀 Running Performance Test for BN_Complex
echo =============================================
call truffle test test\performance\simple-performance-test.js --network besu --grep "BN_Complex"
if errorlevel 1 echo ❌ BN_Complex Failed

echo.
echo 🏁 All tests completed.
echo 📊 Generating visual report...
call node test\performance\generate-report.js
echo ✅ Report generated: test\performance\results\report.html
echo 📊 Check CSV results in test\performance\results\performance-data.csv
