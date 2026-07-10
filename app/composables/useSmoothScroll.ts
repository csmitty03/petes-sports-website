export function useSmoothScroll() {
  function scrollToHash(hash: string) {
    if (!hash.startsWith('#') || hash === '#') return false

    const target = document.querySelector(hash)
    if (!target) return false

    target.scrollIntoView({ behavior: 'smooth', block: 'start' })
    return true
  }

  function handleAnchorClick(event: MouseEvent, href: string) {
    if (!href.startsWith('#')) return

    if (scrollToHash(href)) {
      event.preventDefault()
    }
  }

  return { scrollToHash, handleAnchorClick }
}