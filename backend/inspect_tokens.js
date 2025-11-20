/**
 * Detailed token inspection for wallet
 * Fetches token metadata to identify tokens properly
 */

require('dotenv').config();
const { Connection, PublicKey, LAMPORTS_PER_SOL } = require('@solana/web3.js');

const WALLET_ADDRESS = 'dadMtf8Dk5H8aZx5DWwhpZzURYV9ocUhQV6L41MyHQS';

async function inspectTokens() {
  try {
    console.log('\n🔍 Deep Token Inspection\n');
    console.log('='.repeat(80));
    
    // Try different RPC endpoints for better reliability
    const rpcEndpoints = [
      'https://api.mainnet-beta.solana.com',
      'https://solana-api.projectserum.com',
      'https://rpc.ankr.com/solana'
    ];
    
    let connection;
    let tokenAccounts;
    
    for (const rpc of rpcEndpoints) {
      try {
        console.log(`\nTrying RPC: ${rpc}`);
        connection = new Connection(rpc, 'confirmed');
        const walletPubkey = new PublicKey(WALLET_ADDRESS);
        
        // Get SOL balance first to verify connection
        const solBalance = await connection.getBalance(walletPubkey);
        console.log(`✅ Connected! SOL Balance: ${(solBalance / LAMPORTS_PER_SOL).toFixed(6)}`);
        
        // Get token accounts
        tokenAccounts = await connection.getParsedTokenAccountsByOwner(
          walletPubkey,
          { programId: new PublicKey('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA') }
        );
        
        console.log(`📦 Token Accounts Found: ${tokenAccounts.value.length}`);
        
        if (tokenAccounts.value.length > 0) {
          console.log('✅ Using this RPC endpoint\n');
          break;
        }
      } catch (err) {
        console.log(`❌ Failed: ${err.message}`);
      }
    }
    
    console.log('='.repeat(80));
    
    if (!tokenAccounts || tokenAccounts.value.length === 0) {
      console.log('\n❌ No tokens found on any RPC endpoint.');
      console.log('This is strange since the screenshot shows tokens.');
      console.log('\n💡 Possible reasons:');
      console.log('   - RPC nodes are out of sync');
      console.log('   - Network issues');
      console.log('   - The tokens were just recently added');
      console.log('\nTry again in a few minutes or check: https://solscan.io/account/' + WALLET_ADDRESS);
      return;
    }
    
    console.log(`\n🪙 Found ${tokenAccounts.value.length} Token Account(s)\n`);
    console.log('='.repeat(80));
    
    for (let i = 0; i < tokenAccounts.value.length; i++) {
      const account = tokenAccounts.value[i];
      const accountData = account.account.data.parsed.info;
      const tokenAmount = accountData.tokenAmount;
      
      console.log(`\n📦 TOKEN ${i + 1}:`);
      console.log('-'.repeat(80));
      console.log('Token Account:     ', account.pubkey.toString());
      console.log('Token Mint:        ', accountData.mint);
      console.log('Owner:             ', accountData.owner);
      console.log('Balance:           ', tokenAmount.uiAmount?.toLocaleString() || 0);
      console.log('Decimals:          ', tokenAmount.decimals);
      console.log('Raw Amount:        ', tokenAmount.amount);
      
      // Check if frozen
      if (accountData.state === 'frozen') {
        console.log('⚠️  Status:          FROZEN');
      } else {
        console.log('✅ Status:          Active');
      }
      
      // Check if it matches BACON mint
      const expectedBaconMint = process.env.SOLANA_TOKEN_MINT_ADDRESS || 'mntjJdXMvLkALMnyYFsdvxUnFXjLzLPpiNQwQSC58BL';
      if (accountData.mint === expectedBaconMint) {
        console.log('🥓 TYPE:            THIS IS YOUR BACON TOKEN! ✅');
      }
      
      // Fetch token metadata if available
      try {
        const mintPubkey = new PublicKey(accountData.mint);
        const mintInfo = await connection.getParsedAccountInfo(mintPubkey);
        
        if (mintInfo.value?.data?.parsed?.info) {
          const info = mintInfo.value.data.parsed.info;
          console.log('\n📋 Token Mint Info:');
          console.log('   Supply:          ', info.supply);
          console.log('   Decimals:        ', info.decimals);
          console.log('   Mint Authority:  ', info.mintAuthority || 'None');
          console.log('   Freeze Authority:', info.freezeAuthority || 'None');
        }
      } catch (metaErr) {
        // Metadata not available, skip
      }
      
      console.log('\n🔗 View on Solscan:');
      console.log('   Token: https://solscan.io/token/' + accountData.mint);
      console.log('   Account: https://solscan.io/account/' + account.pubkey.toString());
    }
    
    console.log('\n' + '='.repeat(80));
    console.log('📊 SUMMARY');
    console.log('='.repeat(80));
    
    const baconMint = process.env.SOLANA_TOKEN_MINT_ADDRESS || 'mntjJdXMvLkALMnyYFsdvxUnFXjLzLPpiNQwQSC58BL';
    const baconAccount = tokenAccounts.value.find(
      acc => acc.account.data.parsed.info.mint === baconMint
    );
    
    if (baconAccount) {
      const balance = baconAccount.account.data.parsed.info.tokenAmount.uiAmount;
      console.log(`\n✅ BACON TOKEN FOUND!`);
      console.log(`   Balance: ${balance?.toLocaleString()} BACON tokens`);
      console.log(`   Mint: ${baconMint}`);
      console.log(`\n🎉 Your backend is ready to transfer BACON tokens!`);
    } else {
      console.log(`\n❌ BACON token NOT found`);
      console.log(`   Expected Mint: ${baconMint}`);
      console.log(`\n💡 The tokens in your wallet might be a different token.`);
      console.log(`   Please verify the token mint address in Phantom.`);
    }
    
    console.log('\n' + '='.repeat(80) + '\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('Stack:', error.stack);
  }
}

inspectTokens();
