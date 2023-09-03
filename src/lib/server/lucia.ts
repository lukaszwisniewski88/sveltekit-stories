// lib/server/lucia.ts
import { dev } from '$app/environment';
import prismaClient from '$lib/config/prisma';
import { prisma } from '@lucia-auth/adapter-prisma';
import { lucia } from 'lucia';
import { sveltekit } from 'lucia/middleware';

export const auth = lucia({
	adapter: prisma(prismaClient, { user: 'authUser', key: 'authKey', session: 'authSession' }),
	env: dev ? 'DEV' : 'PROD',
	middleware: sveltekit(),
	getUserAttributes: (userData) => {
		return {
			email: userData.email,
			firstName: userData.firstName,
			lastName: userData.lastName,
			role: userData.role,
			verified: userData.verified,
			receiveEmail: userData.receiveEmail,
			token: userData.token
		};
	}
});

export type Auth = typeof auth;
