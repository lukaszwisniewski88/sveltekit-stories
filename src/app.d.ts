// src/app.d.ts
declare global {
	namespace App {
		interface Locals {
			auth: import('lucia').AuthRequest;
			user: Lucia.UserAttributes;
			startTimer: number;
			error: string;
			errorId: string;
			errorStackTrace: string;
			message: unknown;
			track: unknown;
		}
		interface Error {
			code?: string;
			errorId?: string;
		}
	}
}

/// <reference types="lucia" />
declare global {
	namespace Lucia {
		type Auth = import('$lib/lucia').Auth;
		type DatabaseUserAttributes = {
			email: string;
			firstName: string;
			lastName: string;
			role: string;
			verified: boolean;
			receiveEmail: boolean;
			token: string;
		};
		type DatabaseSessionAttributes = {};
	}
}

// THIS IS IMPORTANT!!!
export {};
