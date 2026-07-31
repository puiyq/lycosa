declare global {
	interface Window {
		nw: {
			Window: {
				get(): {
					zoomLevel: number;
				};
			};
		};
	}
}

((): void => {
	const zoomFactor = 0.65;
	const zoomLevel = Math.log(zoomFactor) / Math.log(1.2);

	const applyZoom = (): void => {
		try {
			window.nw.Window.get().zoomLevel = zoomLevel;
		} catch {
			// Browser-level zoom requires NW access on the remote origin.
		}
	};

	applyZoom();
	window.addEventListener("DOMContentLoaded", applyZoom, { once: true });
	window.addEventListener("load", applyZoom, { once: true });
})();

export {};
