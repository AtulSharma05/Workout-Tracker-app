# Solana Blockchain Integration Guide

This guide explains how to set up and use the BACON token transfer endpoint on Solana mainnet.

## 🚀 Quick Start

### 1. Prerequisites
- Solana wallet with SOL for transaction fees (~0.001 SOL per transaction)
- BACON SPL token mint address
- Wallet private key in base58 format

### 2. Environment Setup

Edit the `.env` file in the backend directory:

```env
# Solana Configuration (Mainnet)
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
SOLANA_PRIVATE_KEY=your_base58_private_key_here
SOLANA_TOKEN_MINT_ADDRESS=your_bacon_token_mint_address_here
```

**⚠️ SECURITY WARNING**: Never commit your `.env` file to git! The private key gives full control over your wallet.

### 3. Get Your Private Key

If you have a Solana wallet from Phantom/Solflare:
1. Export your private key from your wallet
2. It should be in base58 format (a long string like: `5J7W...abc123`)
3. Paste it in the `.env` file

If you're creating a new wallet programmatically:
```bash
# Install Solana CLI
npm install -g @solana/web3.js

# Generate a new keypair (will be saved as JSON)
solana-keygen new --outfile ~/my-wallet.json
```

### 4. Get Your Token Mint Address

This is the unique address of your BACON token on Solana. You can find it:
- In your SPL token creation transaction
- On Solscan.io under your token details
- From your token creation tool (e.g., Token Creator dApp)

Example mint address: `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`

### 5. Fund Your Wallet

Your wallet needs:
1. **SOL**: For transaction fees (~0.001 SOL per transfer)
   - Send SOL from an exchange or another wallet
   - Minimum recommended: 0.1 SOL

2. **BACON Tokens**: The tokens you want to distribute
   - Mint tokens to your wallet address
   - Or receive from another source

---

## 📡 API Endpoints

### Base URL
```
http://localhost:3000/api/v1/solana
```

### 1. Transfer Tokens
Transfer BACON tokens to a user's wallet.

**Endpoint**: `POST /transfer`

**Request Body**:
```json
{
  "recipientWallet": "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU",
  "amount": 100
}
```

**Response (Success)**:
```json
{
  "success": true,
  "message": "Tokens transferred successfully",
  "data": {
    "success": true,
    "signature": "5j7s8K...",
    "explorerUrl": "https://solscan.io/tx/5j7s8K...",
    "from": "YourWalletPublicKey...",
    "to": "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU",
    "amount": 100,
    "timestamp": "2024-01-15T10:30:00.000Z"
  }
}
```

**Response (Error)**:
```json
{
  "success": false,
  "message": "Invalid Solana wallet address"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:3000/api/v1/solana/transfer \
  -H "Content-Type: application/json" \
  -d '{
    "recipientWallet": "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU",
    "amount": 100
  }'
```

---

### 2. Check Token Balance
Get the BACON token balance for any wallet.

**Endpoint**: `GET /balance/:walletAddress`

**Example**:
```
GET /balance/7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU
```

**Response**:
```json
{
  "success": true,
  "data": {
    "walletAddress": "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU",
    "balance": 1500.5,
    "unit": "BACON"
  }
}
```

**cURL Example**:
```bash
curl http://localhost:3000/api/v1/solana/balance/7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU
```

---

### 3. Get Backend Wallet Info
Get information about the backend wallet (address and SOL balance).

**Endpoint**: `GET /wallet-info`

**Response**:
```json
{
  "success": true,
  "data": {
    "walletAddress": "YourBackendWalletPublicKey...",
    "solBalance": 0.5,
    "status": "active"
  }
}
```

**cURL Example**:
```bash
curl http://localhost:3000/api/v1/solana/wallet-info
```

---

## 🔧 Testing

### Test with Postman
1. Create a new POST request to `http://localhost:3000/api/v1/solana/transfer`
2. Set Headers: `Content-Type: application/json`
3. Set Body (raw JSON):
```json
{
  "recipientWallet": "YOUR_TEST_WALLET_ADDRESS",
  "amount": 10
}
```
4. Send the request
5. Check the `explorerUrl` in the response to verify the transaction

### Test with Frontend (Flutter)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> transferBaconTokens(String recipientWallet, double amount) async {
  final url = Uri.parse('http://localhost:3000/api/v1/solana/transfer');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'recipientWallet': recipientWallet,
      'amount': amount,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Transaction successful!');
    print('Explorer URL: ${data['data']['explorerUrl']}');
  } else {
    print('Error: ${response.body}');
  }
}
```

---

## ⚠️ Common Issues

### 1. "SOLANA_PRIVATE_KEY not found"
- Make sure `.env` file exists in the backend directory
- Check that `SOLANA_PRIVATE_KEY` is set correctly
- Restart the backend server after editing `.env`

### 2. "Invalid recipient wallet address"
- Wallet address must be a valid base58 Solana address
- Check for typos or extra spaces
- Use a wallet address from Phantom, Solflare, or similar

### 3. "Insufficient token balance"
- Your backend wallet doesn't have enough BACON tokens
- Check balance with the `/wallet-info` endpoint
- Transfer more tokens to your backend wallet

### 4. "Insufficient SOL for transaction fees"
- Your wallet needs SOL to pay for transaction fees
- Each transfer costs ~0.00001 SOL
- Add at least 0.1 SOL to your wallet

### 5. RPC Rate Limiting
- Free RPC endpoints have rate limits
- Consider using paid RPC providers:
  - QuickNode: https://www.quicknode.com/
  - Alchemy: https://www.alchemy.com/
  - GenesysGo: https://www.genesysgo.com/

---

## 🔒 Security Best Practices

### Never Expose Private Keys
- ✅ Store in `.env` file (gitignored)
- ✅ Use environment variables in production
- ❌ Never commit to GitHub
- ❌ Never share in logs or error messages

### Use Environment Variables in Production
```javascript
// Good
const privateKey = process.env.SOLANA_PRIVATE_KEY;

// Bad
const privateKey = "5J7W...abc123"; // Hardcoded!
```

### Add Authentication Middleware
Protect the `/transfer` endpoint:

```javascript
// In solanaRoutes.js
const { protect } = require('../middleware/auth');

router.post('/transfer', protect, solanaController.transferTokens);
```

### Rate Limiting
The backend already has rate limiting enabled. Consider adding specific limits for the Solana endpoint:

```javascript
const transferLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // 5 transfers per minute
  message: 'Too many token transfers. Please try again later.'
});

router.post('/transfer', transferLimiter, solanaController.transferTokens);
```

### Monitor Transactions
- Set up alerts for large transfers
- Keep logs of all transactions
- Regularly check wallet balance
- Monitor transaction fees

---

## 📊 Transaction Monitoring

### View on Solscan
Every successful transfer returns an `explorerUrl`:
```
https://solscan.io/tx/{signature}
```

You can see:
- Transaction status (Success/Failed)
- Token amount transferred
- Sender and recipient addresses
- Transaction fees
- Timestamp
- Block confirmation

### Check Wallet Balance
```bash
# Using Solana CLI
solana balance <WALLET_ADDRESS>

# Using the API
curl http://localhost:3000/api/v1/solana/wallet-info
```

---

## 🎯 Integration Examples

### Reward Users After Workout
```javascript
// After completing a workout
const userId = req.user.id;
const userWallet = req.user.solanaWallet;
const rewardAmount = 50; // 50 BACON tokens

const result = await solanaService.transferTokens(userWallet, rewardAmount);

// Save to database
await UserReward.create({
  userId,
  amount: rewardAmount,
  txSignature: result.signature,
  timestamp: new Date()
});
```

### Daily Login Bonus
```javascript
// Check last login
if (isFirstLoginToday(user)) {
  const dailyBonus = 10; // 10 BACON tokens
  await solanaService.transferTokens(user.solanaWallet, dailyBonus);
}
```

### Achievement Rewards
```javascript
const achievementRewards = {
  'first_workout': 100,
  '10_workouts': 500,
  '100_workouts': 2000,
  'perfect_form': 250
};

const rewardAmount = achievementRewards[achievementType];
await solanaService.transferTokens(user.solanaWallet, rewardAmount);
```

---

## 🛠️ Advanced Configuration

### Use Faster RPC Endpoints
Edit `.env`:
```env
# Premium RPC (faster, more reliable)
SOLANA_RPC_URL=https://rpc.ankr.com/solana
# or
SOLANA_RPC_URL=https://your-quicknode-endpoint.com
```

### Custom Commitment Levels
Edit `solanaService.js`:
```javascript
this.connection = new Connection(rpcUrl, 'finalized'); // More confirmations
// or
this.connection = new Connection(rpcUrl, 'confirmed'); // Default
// or
this.connection = new Connection(rpcUrl, 'processed'); // Fastest
```

### Transaction Priority Fees
Add priority fees for faster processing during network congestion (future enhancement).

---

## 📝 Logging

The service logs all operations:

```
🔗 Connected to Solana RPC: https://api.mainnet-beta.solana.com
💰 Wallet loaded: YourPublicKey...
🪙 Token Mint Address: TokenMintAddress...
💵 Wallet SOL Balance: 0.5 SOL
✅ Solana service initialized successfully

🚀 Starting token transfer...
📤 From: BackendWallet...
📥 To: UserWallet...
🪙 Amount: 100 tokens
✅ Transaction confirmed!
🔗 Explorer: https://solscan.io/tx/5j7s8K...
```

---

## 🎉 Next Steps

1. **Set up your wallet**: Add private key and token mint address to `.env`
2. **Fund your wallet**: Add SOL for fees and BACON tokens
3. **Test the endpoint**: Use Postman or cURL
4. **Integrate with app**: Add token rewards for workouts/achievements
5. **Add authentication**: Protect endpoints with JWT middleware
6. **Monitor transactions**: Set up logging and alerts
7. **Scale**: Consider paid RPC providers for production

---

## 🆘 Support

- **Solana Documentation**: https://docs.solana.com/
- **SPL Token Guide**: https://spl.solana.com/token
- **Solscan Explorer**: https://solscan.io/
- **Solana Stack Exchange**: https://solana.stackexchange.com/

---

**Built with ❤️ for the Workout Tracker App**
