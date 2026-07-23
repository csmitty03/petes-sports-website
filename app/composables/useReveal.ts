export function useReveal() {
  const isVisible = ref(false)
  const element = ref<HTMLElement | null>(null)

  onMounted(() => {
    if (!element.value) return

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            isVisible.value = true
          }
        })
      },
      { threshold: 0.1, rootMargin: '0px 0px -40px 0px' },
    )

    observer.observe(element.value)
    onUnmounted(() => observer.disconnect())
  })

  return { element, isVisible }
}