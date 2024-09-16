const express = require('express');
const cors = require('cors');  // Add CORS support
const stripe = require('stripe')('sk_test_51PpRH6L7dY78ZxcIVW00yeLPPk7CUPfPybcDiijtYsgMaHyJPjvKJim1PTAZ295WJjXrLt8E4FSHwBQn0iw9z0Km00JRRs1X9N');  // Use environment variable for security
const app = express();
app.use(express.json());
app.use(cors());  // Enable CORS for all routes

// Route to create payment intent
app.post('/create-payment-intent', async (req, res) => {
  const { amount } = req.body;

  if (!amount || isNaN(amount)) {
    return res.status(400).json({ error: 'Invalid amount' });
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Stripe uses the smallest currency unit (e.g., cents)
      currency: 'usd',
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    console.error('Error creating payment intent:', error);  // Log error for debugging
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Start the server
const PORT = process.env.PORT || 3001;  // Use environment variable or default to 3001
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
