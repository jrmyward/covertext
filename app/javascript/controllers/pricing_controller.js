import { Controller } from "@hotwired/stimulus"

// Updates pricing card CTA URLs when billing interval (monthly/yearly) changes
export default class extends Controller {
  static targets = ["cta"]

  connect() {
    // Update URLs on initial load
    this.updateAllUrls()
  }

  updateAllUrls() {
    const interval = this.getSelectedInterval()

    // Find all pricing cards and update their CTAs
    this.ctaTargets.forEach(cta => {
      const plan = cta.dataset.plan
      const newUrl = `/signup?plan=${plan}&interval=${interval}`
      cta.href = newUrl
    })
  }

  getSelectedInterval() {
    const checkedRadio = this.element.querySelector('input[name="pricing-tab"]:checked')
    return checkedRadio ? checkedRadio.value : 'yearly'
  }
}
