/**
 * A prompt inbox for a terminal: text dropped in the file named by PI_PROMPT_INBOX becomes a user message, as if typed
 * and sent. Pi's own keyboard field takes no suggestions in a terminal tile, so the phone's glide typing does nothing
 * there; a widget's text field has them, and hands what it swipes to this. Only a session started with PI_PROMPT_INBOX
 * set watches a file, so every other session of Pi is untouched.
 */

import { existsSync, readFileSync, renameSync, unlinkSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	const inbox = process.env.PI_PROMPT_INBOX;
	if (!inbox) return;

	let timer: ReturnType<typeof setInterval> | undefined;
	let idle = () => true;

	// While a run streams, a message has to say how it waits its turn: queued behind it, not steering it.
	function send(text: string) {
		try {
			pi.sendUserMessage(text, idle() ? undefined : { deliverAs: "followUp" });
		} catch {
			// Idle as the check ran, streaming by the time it got there: queue it after the run instead.
			pi.sendUserMessage(text, { deliverAs: "followUp" });
		}
	}

	// The writer renames a whole prompt over the inbox, so this never reads half of one.
	function drain() {
		const ready = `${inbox}.ready`;
		try {
			if (!existsSync(inbox)) return;
			renameSync(inbox, ready);
			const text = readFileSync(ready, "utf8").trim();
			unlinkSync(ready);
			if (text) send(text);
		} catch {
			// Gone under this tick, or unreadable: the next one looks again.
		}
	}

	pi.on("session_start", (event, ctx) => {
		idle = () => ctx.isIdle();
		// A prompt written before this session started was not meant for it.
		try {
			unlinkSync(inbox);
		} catch {
			// There is none.
		}
		timer = setInterval(drain, 250);
	});

	pi.on("session_shutdown", () => {
		if (timer !== undefined) clearInterval(timer);
		timer = undefined;
	});
}
