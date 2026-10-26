// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';

// https://astro.build/config
export default defineConfig({
	site: 'https://cloudkit-cli.pages.dev',
	integrations: [
		starlight({
			title: 'CloudKit',
			description: 'One ck command for AWS and Google Cloud.',
			logo: { src: './src/assets/logo-icon.svg' },
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/shabayekdes/cloudkit-cli' },
			],
			editLink: {
				baseUrl: 'https://github.com/shabayekdes/cloudkit-cli/edit/main/website/',
			},
			plugins: [starlightLinksValidator()],
			sidebar: [
				{
					label: 'Start here',
					items: ['getting-started', 'sessions'],
				},
				{
					label: 'Commands',
					items: [{ autogenerate: { directory: 'commands' } }],
				},
				{
					label: 'Reference',
					items: ['configuration', 'troubleshooting'],
				},
				{ label: 'Contributing', slug: 'contributing' },
			],
		}),
	],
});
