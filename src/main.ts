import { app, BrowserWindow, Menu } from "electron";
import type { HIDDevice } from "electron";
import path from "node:path";

const TARGET_URL = "https://hero.aulastar.com/keyboard";
const VENDOR_ID = 14126;
const PRODUCT_ID = 4158;
const DEFAULT_ZOOM_FACTOR = 1;
const ZOOM_FACTOR = Number.parseFloat(process.env.LYCOSA_ZOOM_FACTOR ?? "") || DEFAULT_ZOOM_FACTOR;

app.commandLine.appendSwitch("enable-features", "WebHID");

function isTargetDevice(device: HIDDevice): boolean {
	return device.vendorId === VENDOR_ID && device.productId === PRODUCT_ID;
}

function createWindow(): void {
	const win = new BrowserWindow({
		title: "Lycosa",
		width: 1100,
		height: 750,
		icon: path.join(__dirname, "icon.png"),
		webPreferences: {
			contextIsolation: true,
			nodeIntegration: false,
		},
	});

	const { webContents } = win;
	const { session } = webContents;

	session.on("select-hid-device", (event, details, callback) => {
		event.preventDefault();
		callback(details.deviceList.find(isTargetDevice)?.deviceId);
	});

	session.setDevicePermissionHandler(
		(details) =>
			details.deviceType === "hid" && isTargetDevice(details.device as HIDDevice),
	);

	session.setPermissionCheckHandler((_wc, permission) => permission === "hid");

	webContents.on("did-finish-load", () => {
		webContents.setZoomFactor(ZOOM_FACTOR);
	});

	win.loadURL(TARGET_URL);
}

app.whenReady().then(() => {
	Menu.setApplicationMenu(null);
	createWindow();
});

app.on("window-all-closed", () => {
	app.quit();
});
