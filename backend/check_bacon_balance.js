/**
 * Debug script to check BACON token balance
 */

require('dotenv').config();
const { Connection, PublicKey } = require('@solana/web3.js');
const { getAssociatedTokenAddress } = require('@solana/spl-token');

async function checkBalance() {
  try {
    console.log('\n🔍 Checking BACON Token Balance...\n');
    
    const connection = new Connection(process.env.SOLANA_RPC_URL, 'confirmed');
    const walletPubkey = new PublicKey('dadMtf8Dk5H8aZx5DWwhpZzURYV9ocUhQV6L41MyHQS');
    const mintPubkey = new PublicKey(process.env.SOLANA_TOKEN_MINT_ADDRESS);
    
    console.log('Wallet:', walletPubkey.toString());
    console.log('Token Mint:', mintPubkey.toString());
    console.log('');
    
    // Calculate the Associated Token Account address
    const ata = await getAssociatedTokenAddress(
      mintPubkey,
      walletPubkey
    );
    
    console.log('Associated Token Account:', ata.toString());
    console.log('');
    
    // Check if account exists
    const accountInfo = await connection.getAccountInfo(ata);
    
    if (!accountInfo) {
      console.log('❌ Token account does NOT exist yet!');
      console.log('   This means no BACON tokens have been sent to this wallet.');
      console.log('   The account will be created when you receive your first BACON tokens.');
      return;
    }
    
    console.log('✅ Token account exists!');
    console.log('');
    
    // Get token balance
    const balance = await connection.getTokenAccountBalance(ata);
    
    console.log('📊 Balance Details:');
    console.log('   Raw Amount:', balance.value.amount);
    console.log('   Decimals:', balance.value.decimals);
    console.log('   UI Amount:', balance.value.uiAmount);
    console.log('');
    console.log(`🪙 BACON Balance: ${balance.value.uiAmount || 0} tokens`);
    
    // Get all token accounts for this wallet
    console.log('\n🔍 All Token Accounts for this wallet:');
    const tokenAccounts = await connection.getParsedTokenAccountsByOwner(
      walletPubkey,
      { programId: new PublicKey('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA') }
    );
    
    if (tokenAccounts.value.length === 0) {
      console.log('   No token accounts found.');
    } else {
      tokenAccounts.value.forEach((account, i) => {
        const mint = account.account.data.parsed.info.mint;
        const amount = account.account.data.parsed.info.tokenAmount.uiAmount;
        const decimals = account.account.data.parsed.info.tokenAmount.decimals;
        console.log(`\n   Account ${i + 1}:`);
        console.log(`   - Mint: ${mint}`);
        console.log(`   - Balance: ${amount}`);
        console.log(`   - Decimals: ${decimals}`);
        console.log(`   - Address: ${account.pubkey.toString()}`);
        
        if (mint === mintPubkey.toString()) {
          console.log(`   ✅ This is your BACON token account!`);
        }
      });
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

checkBalance();
