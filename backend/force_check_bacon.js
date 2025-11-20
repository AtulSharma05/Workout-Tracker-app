/**
 * Force fresh check with finalized commitment
 */

require('dotenv').config();
const { Connection, PublicKey } = require('@solana/web3.js');
const { getAssociatedTokenAddress, getAccount } = require('@solana/spl-token');

async function forceCheck() {
  console.log('\n🔍 Force Checking Token Account (Finalized Commitment)\n');
  
  const wallet = new PublicKey('dadMtf8Dk5H8aZx5DWwhpZzURYV9ocUhQV6L41MyHQS');
  const mint = new PublicKey('mntjJdXMvLkALMnyYFsdvxUnFXjLzLPpiNQwQSC58BL');
  
  console.log('Wallet:', wallet.toString());
  console.log('Mint:  ', mint.toString());
  console.log('');
  
  // Try with 'finalized' commitment for most up-to-date data
  const connection = new Connection('https://api.mainnet-beta.solana.com', 'finalized');
  
  try {
    // Calculate ATA
    const ata = await getAssociatedTokenAddress(mint, wallet);
    console.log('Calculated ATA:', ata.toString());
    console.log('');
    
    // Check if account exists
    console.log('Checking account existence...');
    const accountInfo = await connection.getAccountInfo(ata, 'finalized');
    
    if (!accountInfo) {
      console.log('❌ Account does NOT exist (with finalized commitment)');
      console.log('');
      console.log('💡 This means either:');
      console.log('   1. No BACON tokens have been sent to this wallet yet');
      console.log('   2. Phantom is showing cached/stale data');
      console.log('   3. You need to send tokens from another wallet first');
      console.log('');
      console.log('🔗 Verify on Solscan:');
      console.log('   https://solscan.io/account/' + wallet.toString());
      return;
    }
    
    console.log('✅ Account EXISTS!');
    console.log('');
    
    // Get account details
    try {
      const tokenAccount = await getAccount(connection, ata, 'finalized');
      console.log('📊 Token Account Details:');
      console.log('   Address:', tokenAccount.address.toString());
      console.log('   Mint:', tokenAccount.mint.toString());
      console.log('   Owner:', tokenAccount.owner.toString());
      console.log('   Amount:', tokenAccount.amount.toString());
      console.log('   Delegate:', tokenAccount.delegate?.toString() || 'None');
      console.log('   State:', tokenAccount.state);
      console.log('   Is Native:', tokenAccount.isNative);
      console.log('   Close Authority:', tokenAccount.closeAuthority?.toString() || 'None');
      
      // Get balance in human-readable format
      const balance = await connection.getTokenAccountBalance(ata, 'finalized');
      console.log('');
      console.log('🪙 BALANCE:', balance.value.uiAmount?.toLocaleString(), 'BACON tokens');
      console.log('   Decimals:', balance.value.decimals);
      console.log('   Raw:', balance.value.amount);
      
    } catch (err) {
      console.log('⚠️  Could not parse account:', err.message);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

forceCheck();
