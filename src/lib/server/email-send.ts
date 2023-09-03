import nodemailer, { type Transporter } from 'nodemailer';
import {
	FROM_EMAIL,
	SMTP_HOST,
	SMTP_PORT,
	SMTP_SECURE,
	SMTP_USER,
	SMTP_PASS
} from '$env/static/private';
//import { z } from "zod";
export default async function sendEmail(
	email: string,
	subject: string,
	bodyHtml?: string,
	bodyText?: string
) {
	let transporter: Transporter;
	// create Nodemailer SMTP transporter
	transporter = nodemailer.createTransport({
		// @ts-ignore
		host: SMTP_HOST,
		port: Number(SMTP_PORT),
		secure: Number(SMTP_SECURE) === 1,
		auth: {
			user: SMTP_USER,
			pass: SMTP_PASS
		}
	});
	interface MailConfig {
		recipient: string;
		subject: string;
		htmlMessage: string;
	}

	try {
		if (!bodyText) {
			transporter.sendMail(
				{
					from: FROM_EMAIL,
					to: email,
					subject: subject,
					html: bodyHtml
				},
				(err, info) => {
					if (err) {
						throw new Error(`Error sending email: ${JSON.stringify(err)}`);
					}
				}
			);
		} else if (!bodyHtml) {
			transporter.sendMail(
				{
					from: FROM_EMAIL,
					to: email,
					subject: subject,
					text: bodyText
				},
				(err, info) => {
					if (err) {
						throw new Error(`Error sending email: ${JSON.stringify(err)}`);
					}
				}
			);
		} else {
			transporter.sendMail(
				{
					from: FROM_EMAIL,
					to: email,
					subject: subject,
					html: bodyHtml,
					text: bodyText
				},
				(err, info) => {
					if (err) {
						throw new Error(`Error sending email: ${JSON.stringify(err)}`);
					}
				}
			);
		}
		console.log('E-mail sent successfully!');
		return {
			statusCode: 200,
			message: 'E-mail sent successfully.'
		};
	} catch (error) {
		throw new Error(`Error sending email: ${JSON.stringify(error)}`);
	}
}
