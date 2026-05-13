<template>
  <div class="max-w-4xl mx-auto px-4 py-12 md:py-20">
    <div class="bg-white rounded-3xl p-8 md:p-12 border border-sand-container shadow-sm">
      <h1 class="text-4xl font-display font-bold text-charcoal mb-8">Privacy & Identity</h1>
      
      <section class="space-y-8 text-charcoal/80 leading-relaxed">
        <div>
          <h2 class="text-xl font-display font-bold text-sage mb-3">How we remember you</h2>
          <p>
            Wilderness Rubric is designed to be used without an account, email, or password. 
            To save your personal rankings and weights, we assign your browser a unique anonymous ID (UUID).
          </p>
        </div>

        <div class="grid md:grid-cols-2 gap-8">
          <div class="bg-sand-container/30 p-6 rounded-2xl border border-sand-container">
            <h3 class="font-bold text-charcoal mb-2">Cookies & Local Storage</h3>
            <p class="text-sm">
              We store your unique ID in your browser's local storage and a functional cookie. 
              This ensures your data stays with you when you return to the site.
            </p>
          </div>
          <div class="bg-sand-container/30 p-6 rounded-2xl border border-sand-container">
            <h3 class="font-bold text-charcoal mb-2">Browser Signals</h3>
            <p class="text-sm">
              We use common browser characteristics (like screen resolution and timezone) to create a 
              unique "fingerprint." This helps us recover your ID if your browser data is cleared, 
              keeping your rankings safe.
            </p>
          </div>
        </div>

        <hr class="border-sand-container" />

        <div>
          <h2 class="text-xl font-display font-bold text-terracotta mb-3">Our commitment</h2>
          <ul class="list-disc pl-5 space-y-4">
            <li>
              <strong>No 3rd Party Tracking:</strong> We do not use advertising trackers, 
              social media pixels, or 3rd party analytics that follow you across the web.
            </li>
            <li>
              <strong>No Selling Data:</strong> Your rankings and IDs are never sold or 
              shared with third parties.
            </li>
          </ul>
        </div>

        <div class="mt-12 pt-8 border-t border-sand-container text-center text-sm text-charcoal/40">
          Last updated: May 2026
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
@reference "../style.css";
</style>
