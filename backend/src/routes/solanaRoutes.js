const express = require('express');
const router = express.Router();
const solanaController = require('../controllers/solanaController');

/**
 * @route   POST /api/v1/solana/transfer
 * @desc    Transfer BACON tokens to a wallet
 * @access  Private (add auth middleware as needed)
 * @body    { recipientWallet: string, amount: number }
 */
router.post('/transfer', solanaController.transferTokens);

/**
 * @route   GET /api/v1/solana/balance/:walletAddress
 * @desc    Get token balance for a wallet address
 * @access  Public
 */
router.get('/balance/:walletAddress', solanaController.getTokenBalance);

/**
 * @route   GET /api/v1/solana/wallet-info
 * @desc    Get backend wallet information (address and SOL balance)
 * @access  Private (add auth middleware as needed)
 */
router.get('/wallet-info', solanaController.getWalletInfo);

module.exports = router;
