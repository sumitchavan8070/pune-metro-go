import type { Metadata } from "next"
import { PolicyPageLayout, PolicyArticle } from "@/components/policy-page-layout"
import { Shield } from "lucide-react"

export const metadata: Metadata = {
  title: {
    absolute: "Privacy Policy for Pune Transit Guide",
  },
  description:
    "Privacy policy for Pune Transit Guide, an independent Pune travel and metro information app for Android and iOS.",
  robots: { index: true, follow: true },
}

const PRIVACY_HTML = `
<div class="space-y-8">
  <p><strong class="text-foreground">Last updated:</strong> 12 November 2026</p>
  <p>This privacy policy explains how the mobile app Pune Transit Guide (formerly "PuneMetro Go") for Android and iOS handles information. Pune Transit Guide is an independent Pune travel and metro information app.</p>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Summary</h2>
    <ul class="list-disc pl-5">
      <li>There is no sign-up or login. We do not collect your name, email address, phone number or date of birth.</li>
      <li>The app does not show ads.</li>
      <li>We do not sell or share your personal information.</li>
    </ul>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Location</h2>
    <p>The app asks for your location only when you use the "Nearby stations" feature. Your location is used on your device to find the closest metro stations. It is not sent to our servers, it is not stored, and it is not tracked in the background. You can turn off location permission at any time in your phone's settings, and the rest of the app will still work.</p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Notifications</h2>
    <p>If you allow notifications, the app uses Firebase Cloud Messaging to send service notices and app updates. To deliver them, Firebase creates a device token for your app installation. We do not link this token to you personally. You can turn off notifications at any time in your phone's settings.</p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Metro data</h2>
    <p>Metro routes, stations, timetables and fares are downloaded from Google Cloud Firestore and saved on your phone so the app can work offline. When your device connects to these services, Google may process technical information such as your IP address, as described in Google's privacy policy.</p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Information stored on your device</h2>
    <p>The app saves your settings (such as light or dark theme) and the downloaded metro data on your device. This information stays on your device and is removed when you uninstall the app.</p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Third-party services</h2>
    <p>The app uses the following Google services, which have their own privacy policies:</p>
    <ul class="list-disc pl-5 mt-3">
      <li>Firebase Cloud Messaging (notifications)</li>
      <li>Google Cloud Firestore (metro data)</li>
      <li>Google Maps (city map)</li>
    </ul>
    <p class="mt-3">Google's privacy policy: <a href="https://policies.google.com/privacy">https://policies.google.com/privacy</a></p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Children</h2>
    <p>The app is not directed at children under 13, and we do not knowingly collect personal information from children.</p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Changes to this policy</h2>
    <p>Any changes to this privacy policy will be posted on this page with a new "Last updated" date.</p>
  </section>

  <section class="scroll-mt-24 rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-4">
    <h2 class="text-lg font-semibold text-foreground mb-3">Disclaimer</h2>
    <p>Pune Transit Guide is an independent app. It is not affiliated with, endorsed by, or operated by Maharashtra Metro Rail Corporation Limited (MAHA-METRO), Pune Metro, or any government body. It does not sell tickets. Metro information comes from publicly available sources and can change.</p>
  </section>

  <section class="scroll-mt-24">
    <h2 class="text-lg font-semibold text-foreground mb-3 pb-2 border-b border-border/60">Contact</h2>
    <p>If you have any questions, suggestions or feedback, please email us at <a href="mailto:supportpunemetrogo@gmail.com">supportpunemetrogo@gmail.com</a>.</p>
  </section>
</div>
`

export default function PuneTransitGuidePrivacyPolicyPage() {
  return (
    <PolicyPageLayout
      title="Privacy Policy for Pune Transit Guide"
      description="How Pune Transit Guide handles user data on Android and iOS"
      icon={<Shield className="w-6 h-6" />}
      footerLabel="Pune Transit Guide · Privacy Policy"
    >
      <PolicyArticle html={PRIVACY_HTML} />
    </PolicyPageLayout>
  )
}
