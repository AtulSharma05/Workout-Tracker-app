const solanaService = require('../services/solanaService');

/**
 * Transfer BACON tokens to a user's wallet
 * POST /api/v1/solana/transfer
 */
const transferTokens = async (req, res) => {
  try {
    const { recipientWallet, amount } = req.body;

    // Validation
    if (!recipientWallet || !amount) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: recipientWallet and amount'
      });
    }

    if (typeof amount !== 'number' || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be a positive number'
      });
    }

    // Execute transfer
    const result = await solanaService.transferTokens(recipientWallet, amount);

    return res.status(200).json({
      success: true,
      message: 'Tokens transferred successfully',
      data: result
    });

  } catch (error) {
    console.error('Transfer error:', error);

    // Handle specific errors
    if (error.message.includes('Invalid recipient wallet address')) {
      return res.status(400).json({
        success: false,
        message: 'Invalid Solana wallet address'
      });
    }

    if (error.message.includes('Insufficient token balance')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to transfer tokens',
      error: error.message
    });
  }
};

/**
 * Get token balance for a wallet
 * GET /api/v1/solana/balance/:walletAddress
 */
const getTokenBalance = async (req, res) => {
  try {
    const { walletAddress } = req.params;

    if (!walletAddress) {
      return res.status(400).json({
        success: false,
        message: 'Wallet address is required'
      });
    }

    const balance = await solanaService.getTokenBalance(walletAddress);

    return res.status(200).json({
      success: true,
      data: {
        walletAddress,
        balance,
        unit: 'BACON'
      }
    });

  } catch (error) {
    console.error('Balance check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get token balance',
      error: error.message
    });
  }
};

/**
 * Get backend wallet information
 * GET /api/v1/solana/wallet-info
 */
const getWalletInfo = async (req, res) => {
  try {
    const walletAddress = solanaService.getWalletAddress();
    const solBalance = await solanaService.getSolBalance();

    return res.status(200).json({
      success: true,
      data: {
        walletAddress,
        solBalance,
        status: 'active'
      }
    });

  } catch (error) {
    console.error('Wallet info error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to get wallet information',
      error: error.message
    });
  }
};

module.exports = {
  transferTokens,
  getTokenBalance,
  getWalletInfo
};
