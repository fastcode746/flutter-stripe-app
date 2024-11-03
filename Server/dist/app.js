"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const dotenv_1 = __importDefault(require("dotenv"));
const cors_1 = __importDefault(require("cors"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const port = process.env.PORT || 8000;
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
app.use(express_1.default.json());
app.use((0, cors_1.default)());
app.post('/secret', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { amount } = req.body;
    try {
        const intent = yield stripe.paymentIntents.create({
            amount: amount,
            currency: 'usd',
            automatic_payment_methods: { enabled: true },
        });
        res.json({ client_secret: intent.client_secret });
    }
    catch (error) {
        console.log(error);
    }
}));
app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
});
//# sourceMappingURL=app.js.map