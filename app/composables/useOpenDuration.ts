export const openedOn = {
  year: 1978,
  month: 3,
  day: 12,
  hour: 0,
  minute: 0,
  second: 0,
  timeZone: 'America/Toronto',
} as const

export interface OpenDuration {
  years: number
  months: number
  days: number
  hours: number
  minutes: number
  seconds: number
}

function zoneParts(date: Date, timeZone: string) {
  const fmt = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    hourCycle: 'h23',
  })

  const map: Record<string, number> = {}
  for (const part of fmt.formatToParts(date)) {
    if (part.type !== 'literal') map[part.type] = Number(part.value)
  }

  return {
    year: map.year,
    month: map.month,
    day: map.day,
    hour: map.hour,
    minute: map.minute,
    second: map.second,
  }
}

function daysInMonth(year: number, month: number) {
  return new Date(year, month, 0).getDate()
}

export function getOpenDuration(now = new Date()): OpenDuration {
  const current = zoneParts(now, openedOn.timeZone)

  let years = current.year - openedOn.year
  let months = current.month - openedOn.month
  let days = current.day - openedOn.day
  let hours = current.hour - openedOn.hour
  let minutes = current.minute - openedOn.minute
  let seconds = current.second - openedOn.second

  if (seconds < 0) {
    seconds += 60
    minutes -= 1
  }
  if (minutes < 0) {
    minutes += 60
    hours -= 1
  }
  if (hours < 0) {
    hours += 24
    days -= 1
  }
  if (days < 0) {
    const prevMonth = current.month === 1 ? 12 : current.month - 1
    const prevYear = current.month === 1 ? current.year - 1 : current.year
    days += daysInMonth(prevYear, prevMonth)
    months -= 1
  }
  if (months < 0) {
    months += 12
    years -= 1
  }

  return { years, months, days, hours, minutes, seconds }
}

export function useOpenDuration() {
  const duration = ref(getOpenDuration())
  let timer: ReturnType<typeof setInterval> | undefined

  onMounted(() => {
    duration.value = getOpenDuration()
    timer = setInterval(() => {
      duration.value = getOpenDuration()
    }, 1000)
  })

  onUnmounted(() => {
    if (timer) clearInterval(timer)
  })

  return { duration }
}
