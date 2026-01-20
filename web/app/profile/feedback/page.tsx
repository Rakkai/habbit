"use client";

import Link from "next/link";
import { useState } from "react";

import { BottomNav } from "../../../components/BottomNav";
import { useRequireWelcome, useSettings } from "../../../lib/hooks";

export default function FeedbackPage() {
  const [message, setMessage] = useState("");
  const [copied, setCopied] = useState(false);
  const { settings } = useSettings();

  useRequireWelcome(settings);

  function handleSend() {
    const email = "luis.amrein@icloud.com";
    const subject = encodeURIComponent("Habbit Feedback");
    const body = encodeURIComponent(message);
    window.location.href = `mailto:${email}?subject=${subject}&body=${body}`;
  }

  async function handleCopy() {
    await navigator.clipboard.writeText("luis.amrein@icloud.com");
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  return (
    <div className="min-h-screen bg-background">
      <div className="container flex flex-col gap-6">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-semibold">Help & Feedback</h1>
          <Link href="/profile" className="text-sm text-success">
            Done
          </Link>
        </div>

        <div className="card rounded-card p-5">
          <h2 className="text-lg font-semibold">I'd love to hear from you!</h2>
          <p className="mt-2 text-sm text-text/60">
            Share your feedback, report a bug, suggest a feature or write me a poem.
          </p>

          <div className="mt-4">
            <label className="text-sm text-text/60">Your message</label>
            <textarea
              value={message}
              onChange={(event) => setMessage(event.target.value)}
              className="mt-2 min-h-[180px]"
            />
          </div>

          <div className="mt-4 flex flex-col gap-3">
            <button className="primary-button" onClick={handleSend} disabled={!message.trim()}>
              Send Feedback
            </button>
            <button className="secondary-button text-sm text-text/70" onClick={handleCopy}>
              {copied ? "Email copied!" : "Copy support email"}
            </button>
          </div>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
