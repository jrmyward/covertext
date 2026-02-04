import { Controller } from "@hotwired/stimulus"

// Handles billing interval toggle on signup form
export default class extends Controller {
  static targets = ["priceDisplay", "intervalField"]
  static values = {
    monthlyPrice: Number,
    yearlyPrice: Number
  }

  updatePrice(event) {
    const interval = event.target.value
    const price = interval === 'yearly' ? this.yearlyPriceValue : this.monthlyPriceValue
    const priceDisplay = interval === 'yearly'
      ? `$${this.yearlyPriceValue}/year`
      : `$${this.monthlyPriceValue}/month`

    this.priceDisplayTarget.textContent = priceDisplay
    this.intervalFieldTarget.value = interval
  }
}
