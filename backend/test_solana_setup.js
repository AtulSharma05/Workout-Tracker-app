/**
 * Test Script for Solana Integration
 * 
 * This script tests the Solana service without making actual transfers.
 * It verifies that the configuration is correct and the service can initialize.
 * 
 * Usage: node test_solana_setup.js
 */

require('dotenv').config();
const solanaService = require('./src/services/solanaService');

async function testSolanaSetup() {
  console.log('\n🧪 Testing Solana Integration Setup...\n');
  console.log('=' .repeat(60));
  
  try {
    // Step 1: Check environment variables
    console.log('\n📋 Step 1: Checking Environment Variables');
    console.log('-'.repeat(60));
    
    const requiredEnvVars = [
      'SOLANA_RPC_URL',
      'SOLANA_PRIVATE_KEY',
      'SOLANA_TOKEN_MINT_ADDRESS'
    ];
    
    let missingVars = [];
    requiredEnvVars.forEach(varName => {
      const value = process.env[varName];
      if (!value || value.includes('your_') || value.includes('here')) {
        console.log(`❌ ${varName}: Not configured`);
        missingVars.push(varName);
      } else {
        console.log(`✅ ${varName}: Configured`);
      }
    });
    
    if (missingVars.length > 0) {
      console.log('\n⚠️  Please configure the following in your .env file:');
      missingVars.forEach(varName => {
        console.log(`   - ${varName}`);
      });
      console.log('\nRefer to SOLANA_SETUP.md for instructions.\n');
      return;
    }
    
    // Step 2: Initialize Solana service
    console.log('\n🔌 Step 2: Initializing Solana Service');
    console.log('-'.repeat(60));
    
    await solanaService.initialize();
    
    // Step 3: Get wallet info
    console.log('\n💼 Step 3: Wallet Information');
    console.log('-'.repeat(60));
    
    const walletAddress = solanaService.getWalletAddress();
    const solBalance = await solanaService.getSolBalance();
    
    console.log(`Wallet Address: ${walletAddress}`);
    console.log(`SOL Balance: ${solBalance.toFixed(4)} SOL`);
    
    if (solBalance < 0.001) {
      console.log('\n⚠️  Warning: SOL balance is very low!');
      console.log('   You need SOL to pay for transaction fees.');
      console.log('   Recommended: At least 0.1 SOL');
    }
    
    // Step 4: Test token balance check (optional)
    console.log('\n🪙 Step 4: Checking Backend Token Balance');
    console.log('-'.repeat(60));
    
    try {
      const tokenBalance = await solanaService.getTokenBalance(walletAddress);
      console.log(`BACON Token Balance: ${tokenBalance} tokens`);
      
      if (tokenBalance === 0) {
        console.log('\n⚠️  Warning: No BACON tokens in wallet!');
        console.log('   You need tokens to distribute to users.');
      }
    } catch (error) {
      console.log('⚠️  Could not fetch token balance:', error.message);
      console.log('   This might be normal if the token account doesn\'t exist yet.');
    }
    
    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('✅ Solana Integration Test Complete!');
    console.log('='.repeat(60));
    console.log('\n📝 Next Steps:');
    console.log('   1. Ensure your wallet has sufficient SOL (>0.1 SOL recommended)');
    console.log('   2. Ensure your wallet has BACON tokens to distribute');
    console.log('   3. Test the API endpoint with a small transfer');
    console.log('   4. Check the transaction on Solscan.io');
    console.log('\n📖 For more info, see: SOLANA_SETUP.md\n');
    
  } catch (error) {
    console.log('\n' + '='.repeat(60));
    console.log('❌ Test Failed!');
    console.log('='.repeat(60));
    console.log('\nError:', error.message);
    console.log('\n💡 Common Issues:');
    console.log('   - Invalid SOLANA_PRIVATE_KEY format (must be base58)');
    console.log('   - Invalid SOLANA_TOKEN_MINT_ADDRESS (must be valid public key)');
    console.log('   - RPC connection issues (check SOLANA_RPC_URL)');
    console.log('   - Network connectivity problems');
    console.log('\n📖 Refer to SOLANA_SETUP.md for troubleshooting.\n');
  }
}

// Run the test
testSolanaSetup();
