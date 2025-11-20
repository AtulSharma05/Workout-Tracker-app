/**
 * Fetch all tokens in a Solana wallet
 * Shows all SPL tokens with their balances
 */

require('dotenv').config();
const { Connection, PublicKey, LAMPORTS_PER_SOL } = require('@solana/web3.js');

const WALLET_ADDRESS = 'dadMtf8Dk5H8aZx5DWwhpZzURYV9ocUhQV6L41MyHQS';

async function fetchAllTokens() {
  try {
    console.log('\n💼 Fetching all tokens for wallet...\n');
    console.log('=' .repeat(70));
    
    const connection = new Connection(
      process.env.SOLANA_RPC_URL || 'https://api.mainnet-beta.solana.com',
      'confirmed'
    );
    
    const walletPubkey = new PublicKey(WALLET_ADDRESS);
    
    console.log('Wallet Address:', walletPubkey.toString());
    console.log('RPC Endpoint:', process.env.SOLANA_RPC_URL);
    console.log('=' .repeat(70));
    
    // 1. Get SOL Balance
    console.log('\n💰 Native SOL Balance:');
    console.log('-'.repeat(70));
    const solBalance = await connection.getBalance(walletPubkey);
    console.log(`   ${(solBalance / LAMPORTS_PER_SOL).toFixed(6)} SOL`);
    
    // 2. Get all SPL Token accounts
    console.log('\n🪙 SPL Token Accounts:');
    console.log('-'.repeat(70));
    
    const tokenAccounts = await connection.getParsedTokenAccountsByOwner(
      walletPubkey,
      { programId: new PublicKey('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA') }
    );
    
    if (tokenAccounts.value.length === 0) {
      console.log('   ❌ No SPL token accounts found.');
      console.log('   This wallet has never received any SPL tokens.');
      console.log('\n💡 Note: Token accounts are created when you first receive tokens.');
      console.log('   Make sure you have the correct wallet address from Phantom.');
      return;
    }
    
    console.log(`   Found ${tokenAccounts.value.length} token account(s)\n`);
    
    // Display each token
    tokenAccounts.value.forEach((account, index) => {
      const accountData = account.account.data.parsed.info;
      const tokenAmount = accountData.tokenAmount;
      
      console.log(`\n📦 Token ${index + 1}:`);
      console.log('-'.repeat(70));
      console.log('   Token Account Address:', account.pubkey.toString());
      console.log('   Token Mint Address:   ', accountData.mint);
      console.log('   Balance:              ', tokenAmount.uiAmount || 0, 'tokens');
      console.log('   Decimals:             ', tokenAmount.decimals);
      console.log('   Raw Amount:           ', tokenAmount.amount);
      
      // Check if it's the BACON token
      if (accountData.mint === process.env.SOLANA_TOKEN_MINT_ADDRESS) {
        console.log('   🥓 This is your BACON token!');
      }
      
      // Check if account is frozen
      if (accountData.state === 'frozen') {
        console.log('   ⚠️  Status: FROZEN');
      }
    });
    
    // 3. Summary
    console.log('\n' + '='.repeat(70));
    console.log('📊 Summary:');
    console.log('-'.repeat(70));
    console.log(`   SOL Balance:          ${(solBalance / LAMPORTS_PER_SOL).toFixed(6)} SOL`);
    console.log(`   SPL Token Accounts:   ${tokenAccounts.value.length}`);
    
    // Check for BACON token specifically
    const baconAccount = tokenAccounts.value.find(
      acc => acc.account.data.parsed.info.mint === process.env.SOLANA_TOKEN_MINT_ADDRESS
    );
    
    if (baconAccount) {
      const baconBalance = baconAccount.account.data.parsed.info.tokenAmount.uiAmount;
      console.log(`   🥓 BACON Tokens:       ${baconBalance}`);
    } else {
      console.log(`   🥓 BACON Tokens:       Not found`);
      console.log(`\n   Expected BACON Mint:   ${process.env.SOLANA_TOKEN_MINT_ADDRESS}`);
      console.log(`   💡 The wallet doesn't have a BACON token account yet.`);
    }
    
    console.log('='.repeat(70) + '\n');
    
    // 4. View on Explorer
    console.log('🔍 View on Solscan:');
    console.log(`   https://solscan.io/account/${WALLET_ADDRESS}\n`);
    
  } catch (error) {
    console.error('\n❌ Error fetching tokens:', error.message);
    console.error('\nStack trace:', error.stack);
  }
}

// Run the script
fetchAllTokens();
