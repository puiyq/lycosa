declare module "electron" {
	export interface HIDDevice {
		vendorId: number;
		productId: number;
		deviceId: string;
	}

	export interface Session {
		on(
			event: "select-hid-device",
			listener: (
				event: { preventDefault(): void },
				details: { deviceList: HIDDevice[] },
				callback: (deviceId?: string) => void,
			) => void,
		): void;
		setDevicePermissionHandler(
			handler: (details: { deviceType: string; device: HIDDevice }) => boolean,
		): void;
		setPermissionCheckHandler(
			handler: (webContents: unknown, permission: string) => boolean,
		): void;
	}

	export interface WebContents {
		session: Session;
		on(event: "did-finish-load", listener: () => void): void;
		setZoomFactor(factor: number): void;
	}

	export interface BrowserWindowConstructorOptions {
		title?: string;
		width?: number;
		height?: number;
		icon?: string;
		webPreferences?: {
			contextIsolation?: boolean;
			nodeIntegration?: boolean;
		};
	}

	export class BrowserWindow {
		constructor(options?: BrowserWindowConstructorOptions);
		webContents: WebContents;
		loadURL(url: string): Promise<void>;
	}

	export const app: {
		commandLine: { appendSwitch(name: string, value?: string): void };
		whenReady(): Promise<void>;
		on(event: "window-all-closed", listener: () => void): void;
		quit(): void;
	};

	export const Menu: {
		setApplicationMenu(menu: null): void;
	};
}

declare module "node:path" {
	export function join(...paths: string[]): string;
}

declare const __dirname: string;
declare const process: {
	env: Record<string, string | undefined>;
};
