# 🚀 Solana Token Transfer API - Quick Reference

## Prerequisites
1. Add to `.env`:
   - `SOLANA_PRIVATE_KEY` (base58 format)
   - `SOLANA_TOKEN_MINT_ADDRESS` (your BACON token address)
   - `SOLANA_RPC_URL` (default: mainnet-beta)

2. Fund wallet:
   - Minimum 0.1 SOL for transaction fees
   - BACON tokens to distribute

3. Install packages (already done):
   ```bash
   npm install @solana/web3.js @solana/spl-token bs58
   ```

---

## 🧪 Test Your Setup

```bash
npm run test-solana
```

This will verify:
- Environment variables are configured
- Wallet can connect to Solana
- SOL balance is sufficient
- Token balance is available

---

## 📡 API Endpoints

### Base URL
```
http://localhost:3000/api/v1/solana
```

---

### 1️⃣ Transfer Tokens

**POST** `/transfer`

**Request:**
```json
{
  "recipientWallet": "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU",
  "amount": 100
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tokens transferred successfully",
  "data": {
    "signature": "5j7s8K9m...",
    "explorerUrl": "https://solscan.io/tx/5j7s8K9m...",
    "from": "YourWalletAddress...",
    "to": "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU",
    "amount": 100,
    "timestamp": "2024-01-15T10:30:00.000Z"
  }
}
```

**cURL:**
```bash
curl -X POST http://localhost:3000/api/v1/solana/transfer \
  -H "Content-Type: application/json" \
  -d '{"recipientWallet": "WALLET_ADDRESS", "amount": 100}'
```

**Errors:**
- `400`: Invalid wallet address or amount
- `500`: Insufficient balance or network error

---

### 2️⃣ Check Balance

**GET** `/balance/:walletAddress`

**Example:**
```
GET /balance/7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU
```

**Response:**
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

**cURL:**
```bash
curl http://localhost:3000/api/v1/solana/balance/WALLET_ADDRESS
```

---

### 3️⃣ Wallet Info

**GET** `/wallet-info`

**Response:**
```json
{
  "success": true,
  "data": {
    "walletAddress": "YourBackendWallet...",
    "solBalance": 0.5,
    "status": "active"
  }
}
```

**cURL:**
```bash
curl http://localhost:3000/api/v1/solana/wallet-info
```

---

## 🎯 Integration Examples

### Flutter/Dart
```dart
Future<void> rewardUser(String wallet, double amount) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/api/v1/solana/transfer'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'recipientWallet': wallet,
      'amount': amount,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('✅ Sent $amount tokens!');
    print('🔗 ${data['data']['explorerUrl']}');
  }
}
```

### JavaScript/Node.js
```javascript
const axios = require('axios');

async function transferTokens(recipientWallet, amount) {
  try {
    const response = await axios.post(
      'http://localhost:3000/api/v1/solana/transfer',
      { recipientWallet, amount }
    );
    
    console.log('✅ Transfer successful!');
    console.log('🔗 Explorer:', response.data.data.explorerUrl);
    return response.data;
  } catch (error) {
    console.error('❌ Transfer failed:', error.response.data.message);
  }
}
```

---

## ⚠️ Common Issues

| Issue | Solution |
|-------|----------|
| "SOLANA_PRIVATE_KEY not found" | Add private key to `.env` and restart server |
| "Invalid recipient wallet address" | Check wallet address format (base58) |
| "Insufficient token balance" | Add more BACON tokens to backend wallet |
| "Insufficient SOL" | Add SOL for transaction fees (0.00001 per tx) |
| RPC rate limiting | Use paid RPC provider or alternative endpoints |

---

## 🔒 Security Checklist

- [x] `.env` file is in `.gitignore`
- [ ] Private key never committed to git
- [ ] Add authentication middleware to `/transfer` endpoint
- [ ] Add rate limiting for transfers
- [ ] Monitor wallet balance regularly
- [ ] Set up transaction alerts
- [ ] Use environment variables in production

---

## 📊 Monitoring

**View Transactions:**
- Every transfer returns `explorerUrl`
- Visit: `https://solscan.io/tx/{signature}`

**Check Wallet:**
```bash
# Using API
curl http://localhost:3000/api/v1/solana/wallet-info

# Using Solana CLI
solana balance YOUR_WALLET_ADDRESS
```

**Logs:**
Server logs show:
```
🚀 Starting token transfer...
📤 From: BackendWallet...
📥 To: UserWallet...
🪙 Amount: 100 tokens
✅ Transaction confirmed!
🔗 Explorer: https://solscan.io/tx/...
```

---

## 📚 Resources

- Full Setup Guide: `SOLANA_SETUP.md`
- Solana Docs: https://docs.solana.com/
- SPL Token: https://spl.solana.com/token
- Solscan Explorer: https://solscan.io/
- Test Script: `npm run test-solana`

---

**🎉 You're ready to distribute BACON tokens on Solana mainnet!**
