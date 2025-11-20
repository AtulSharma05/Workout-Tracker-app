const { 
  Connection, 
  PublicKey, 
  Keypair, 
  Transaction,
  sendAndConfirmTransaction,
  clusterApiUrl
} = require('@solana/web3.js');
const { 
  createTransferInstruction,
  getOrCreateAssociatedTokenAccount,
  TOKEN_PROGRAM_ID,
  ASSOCIATED_TOKEN_PROGRAM_ID
} = require('@solana/spl-token');
const bs58 = require('bs58');

/**
 * Solana Token Transfer Service
 * Handles BACON token transfers on Solana mainnet
 */
class SolanaService {
  constructor() {
    this.connection = null;
    this.wallet = null;
    this.tokenMintAddress = null;
    this.initialized = false;
  }

  /**
   * Initialize Solana connection and wallet
   */
  async initialize() {
    try {
      // Connect to Solana mainnet
      const rpcUrl = process.env.SOLANA_RPC_URL || 'https://api.mainnet-beta.solana.com';
      this.connection = new Connection(rpcUrl, 'confirmed');
      
      console.log('🔗 Connected to Solana RPC:', rpcUrl);

      // Load wallet from private key
      const privateKeyString = process.env.SOLANA_PRIVATE_KEY;
      if (!privateKeyString) {
        throw new Error('SOLANA_PRIVATE_KEY not found in environment variables');
      }

      // Support both byte array and base58 formats
      let privateKeyBytes;
      
      // Check if it's a byte array format (starts with '[')
      if (privateKeyString.trim().startsWith('[')) {
        // Parse JSON array of bytes
        privateKeyBytes = new Uint8Array(JSON.parse(privateKeyString));
      } else {
        // Assume it's base58 format
        privateKeyBytes = bs58.decode(privateKeyString);
      }
      
      this.wallet = Keypair.fromSecretKey(privateKeyBytes);
      
      console.log('💰 Wallet loaded:', this.wallet.publicKey.toString());

      // Load token mint address
      this.tokenMintAddress = new PublicKey(process.env.SOLANA_TOKEN_MINT_ADDRESS);
      console.log('🪙 Token Mint Address:', this.tokenMintAddress.toString());

      // Verify wallet has SOL for transaction fees
      const balance = await this.connection.getBalance(this.wallet.publicKey);
      const solBalance = balance / 1e9;
      console.log(`💵 Wallet SOL Balance: ${solBalance} SOL`);

      if (solBalance < 0.01) {
        console.warn('⚠️ Warning: Low SOL balance. You need SOL for transaction fees!');
      }

      this.initialized = true;
      console.log('✅ Solana service initialized successfully');
      
      return true;
    } catch (error) {
      console.error('❌ Failed to initialize Solana service:', error.message);
      throw error;
    }
  }

  /**
   * Transfer BACON tokens to a wallet address
   * @param {string} recipientAddress - Recipient's Solana wallet address
   * @param {number} amount - Amount of tokens to transfer (in token units, not lamports)
   * @returns {Promise<object>} Transaction details
   */
  async transferTokens(recipientAddress, amount) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      console.log('\n🚀 Starting token transfer...');
      console.log('📤 From:', this.wallet.publicKey.toString());
      console.log('📥 To:', recipientAddress);
      console.log('🪙 Amount:', amount, 'tokens');

      // Validate recipient address
      let recipientPublicKey;
      try {
        recipientPublicKey = new PublicKey(recipientAddress);
      } catch (error) {
        throw new Error('Invalid recipient wallet address');
      }

      // Get or create sender's token account
      console.log('🔍 Getting sender token account...');
      const senderTokenAccount = await getOrCreateAssociatedTokenAccount(
        this.connection,
        this.wallet,
        this.tokenMintAddress,
        this.wallet.publicKey
      );
      console.log('✅ Sender token account:', senderTokenAccount.address.toString());

      // Get or create recipient's token account
      console.log('🔍 Getting recipient token account...');
      const recipientTokenAccount = await getOrCreateAssociatedTokenAccount(
        this.connection,
        this.wallet,
        this.tokenMintAddress,
        recipientPublicKey
      );
      console.log('✅ Recipient token account:', recipientTokenAccount.address.toString());

      // Check sender's token balance
      const senderBalance = await this.connection.getTokenAccountBalance(senderTokenAccount.address);
      const senderBalanceAmount = parseFloat(senderBalance.value.uiAmount);
      console.log(`💰 Sender token balance: ${senderBalanceAmount} tokens`);

      if (senderBalanceAmount < amount) {
        throw new Error(`Insufficient token balance. Required: ${amount}, Available: ${senderBalanceAmount}`);
      }

      // Convert amount to smallest unit (considering decimals)
      const decimals = senderBalance.value.decimals;
      const transferAmount = amount * Math.pow(10, decimals);
      
      console.log(`🔢 Transfer amount (with ${decimals} decimals):`, transferAmount);

      // Create transfer instruction
      const transferInstruction = createTransferInstruction(
        senderTokenAccount.address,     // Source token account
        recipientTokenAccount.address,  // Destination token account
        this.wallet.publicKey,          // Owner of source account
        transferAmount,                 // Amount (in smallest units)
        [],                             // Multi-signers (none in this case)
        TOKEN_PROGRAM_ID
      );

      // Create and send transaction
      console.log('📝 Creating transaction...');
      const transaction = new Transaction().add(transferInstruction);
      
      // Get recent blockhash
      const { blockhash, lastValidBlockHeight } = await this.connection.getLatestBlockhash('confirmed');
      transaction.recentBlockhash = blockhash;
      transaction.feePayer = this.wallet.publicKey;

      console.log('✍️ Signing transaction...');
      transaction.sign(this.wallet);

      console.log('📡 Sending transaction...');
      const signature = await this.connection.sendRawTransaction(
        transaction.serialize(),
        {
          skipPreflight: false,
          preflightCommitment: 'confirmed'
        }
      );

      console.log('⏳ Waiting for confirmation...');
      const confirmation = await this.connection.confirmTransaction({
        signature,
        blockhash,
        lastValidBlockHeight
      }, 'confirmed');

      if (confirmation.value.err) {
        throw new Error('Transaction failed: ' + JSON.stringify(confirmation.value.err));
      }

      const explorerUrl = `https://solscan.io/tx/${signature}`;
      
      console.log('✅ Transaction confirmed!');
      console.log('🔗 Explorer:', explorerUrl);
      console.log('📝 Signature:', signature);

      return {
        success: true,
        signature,
        explorerUrl,
        from: this.wallet.publicKey.toString(),
        to: recipientAddress,
        amount,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      console.error('❌ Token transfer failed:', error.message);
      throw error;
    }
  }

  /**
   * Get token balance for an address
   * @param {string} walletAddress - Wallet address to check
   * @returns {Promise<number>} Token balance
   */
  async getTokenBalance(walletAddress) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      const publicKey = new PublicKey(walletAddress);
      const tokenAccount = await getOrCreateAssociatedTokenAccount(
        this.connection,
        this.wallet,
        this.tokenMintAddress,
        publicKey
      );

      const balance = await this.connection.getTokenAccountBalance(tokenAccount.address);
      return parseFloat(balance.value.uiAmount);
    } catch (error) {
      console.error('Failed to get token balance:', error.message);
      return 0;
    }
  }

  /**
   * Get wallet SOL balance
   * @returns {Promise<number>} SOL balance
   */
  async getSolBalance() {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      const balance = await this.connection.getBalance(this.wallet.publicKey);
      return balance / 1e9; // Convert lamports to SOL
    } catch (error) {
      console.error('Failed to get SOL balance:', error.message);
      return 0;
    }
  }

  /**
   * Get wallet public key
   * @returns {string} Wallet public key
   */
  getWalletAddress() {
    return this.wallet ? this.wallet.publicKey.toString() : null;
  }
}

// Export singleton instance
module.exports = new SolanaService();
