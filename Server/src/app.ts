import express, { Express, Request, Response } from "express";
import path from "path";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 8000;
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.use(express.json());
app.use(cors());

interface RequestBody {
  amount: number
}

app.post('/secret', async (req: Request, res: Response) => {
  const { amount }:RequestBody = req.body;

  try {
    const intent = await stripe.paymentIntents.create({
      amount: amount,
      currency: 'usd',
      automatic_payment_methods: {enabled: true},
    });

    res.json({ client_secret: intent.client_secret });
  } catch (error) {
    console.log(error);
  }
});

app.listen(port, () => {
  console.log(`Stripe app listening on port ${port}`)
});
