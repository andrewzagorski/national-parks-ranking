<template>
  <div class="mx-auto max-w-4xl px-4 py-12 md:py-20">
    <div
      class="border-background-highlight rounded-3xl border bg-white p-8 shadow-sm md:p-12"
    >
      <h1 class="font-display mb-8 text-4xl font-bold">About</h1>

      <section class="space-y-8/80 leading-relaxed">
        <div>
          <h2 class="font-display text-primary mb-3 text-xl font-bold">
            About this app
          </h2>
          <p>
            The parks rubric was built buy a guy in Seattle who loves our
            national parks. The source code is available on
            <a
              href="https://github.com/andrewzagorski/national-parks-ranking"
              target="_blank"
              rel="noopener"
              class="text-secondary hover:text-secondary-tint hover:underline"
              >GitHub</a
            >.
          </p>
        </div>

        <div>
          <h2 class="font-display text-primary mb-3 pt-8 text-xl font-bold">
            Usage
          </h2>
          <p>
            All photographs are either public domain images from the
            <a
              href="https://npgallery.nps.gov/"
              target="_blank"
              rel="noopener"
              class="text-secondary hover:text-secondary-tint hover:underline"
              >National Park Service Gallery</a
            >
            or submitted by users or contributors and available for public use.
            Any reproduction, distribution, or commercial use of this app or its
            contents is prohibited without explicit written permission from the
            author.
          </p>
        </div>

        <div>
          <h2 class="font-display text-primary mb-3 pt-8 text-xl font-bold">
            How we remember you
          </h2>
          <p>
            The Parks Rubric is designed to be used without an account, email,
            or password. To save your personal rankings and weights, we assign
            you a unique anonymous ID (UUID). Don't lose it!
          </p>
        </div>

        <div class="grid gap-8 md:grid-cols-1">
          <div
            class="bg-background-highlight/30 border-background-highlight rounded-2xl border p-6"
          >
            <h3 class="text-secondary-tint mb-2 font-bold">
              Cookies & Local Storage
            </h3>
            <p class="text-sm">
              We store your unique ID in your browser's local storage and a
              functional cookie. This ensures your data stays with you when you
              return to the site.
            </p>
          </div>
        </div>

        <hr class="border-background-highlight" />

        <div>
          <h2 class="font-display text-primary mb-3 pt-8 text-xl font-bold">
            Our commitment
          </h2>
          <ul class="list-disc space-y-4 pl-5">
            <li>
              <strong>No 3rd Party Tracking:</strong> We do not use advertising
              trackers, social media pixels, or 3rd party analytics that follow
              you across the web.
            </li>
            <li>
              <strong>No Selling Data:</strong> Your rankings and IDs are never
              sold or shared with third parties.
            </li>
          </ul>
        </div>

        <div
          class="border-background-highlight mt-12 border-t pt-8 text-center text-sm"
        >
          Last updated: May 2026
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
@reference "../assets/main.css";
</style>
