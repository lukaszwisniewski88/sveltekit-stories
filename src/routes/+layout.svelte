<script lang="ts">
	import '../app.postcss';
	import { AppBar, AppShell, Avatar, Drawer, Modal, Toast } from '@skeletonlabs/skeleton';
	import Navigation from '$lib/components/navigation.svelte';
	import { APP_NAME } from '$lib/config/constants';
	import Footer from '$lib/components/footer.svelte';
	import { Menu } from 'lucide-svelte';
	import { initializeStores } from '@skeletonlabs/skeleton';
	import convertNameToInitials from '$lib/_helpers/convertNameToInitials';
	import { onMount } from 'svelte';
	export let data;
	import { getDrawerStore } from '@skeletonlabs/skeleton';
	initializeStores();
	const drawerStore = getDrawerStore();
	let initials = '';
	onMount(() => {
		if (data?.user?.firstName && data?.user?.lastName) {
			initials = convertNameToInitials(data?.user?.firstName, data?.user?.lastName);
		}
	});
	$: initials = initials;
</script>

<Toast position="tr"></Toast>
<Modal></Modal>
<Drawer>
	<Navigation user={data.user}></Navigation>
</Drawer>

<AppShell slotSidebarLeft="w-0 md:w-52 bg-surface-500/10">
	<svelte:fragment slot="header">
		<AppBar>
			<svelte:fragment slot="lead">
				<button
					class="md:hidden btn btn-sm mr-4"
					aria-label="Menu Button"
					on:click={() => drawerStore.open()}
				>
					<span>
						<Menu></Menu>
					</span>
				</button>
				<strong class="text-xl uppercase">{APP_NAME}</strong>
			</svelte:fragment>
			<svelte:fragment slot="trail">
				{#if data?.user}<Avatar {initials} width="w-10" background="bg-primary-500"></Avatar>{/if}
			</svelte:fragment>
		</AppBar>
	</svelte:fragment>
	<svelte:fragment slot="sidebarLeft">
		<Navigation user={data.user}></Navigation>
	</svelte:fragment>
	<!-- Main Content -->
	<div class="container lg:p-10 mx-auto flex-1">
		<slot />
	</div>
	<svelte:fragment slot="pageFooter"><Footer></Footer></svelte:fragment>
</AppShell>
