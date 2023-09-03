import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async (event) => {
	const { user } = await event.locals.auth.validate();
	if (!user) throw redirect(302, '/auth/sign-in');
	return {
		user
	};
};
