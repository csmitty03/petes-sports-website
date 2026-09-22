export type InquiryType = 'store' | 'sales' | 'storeManager' | 'manager'

export interface Person {
  initials: string
  name: string
  role: string
  location: string
  email?: string
  phone?: string
  lead?: boolean
}

export function telHref(phone: string) {
  const digits = phone.replace(/\D/g, '')
  if (!digits) return ''
  return `tel:+${digits.startsWith('1') ? digits : `1${digits}`}`
}

export interface Service {
  title: string
  description: string
  tag?: string
  link?: string
  linkLabel?: string
}

export interface Location {
  title: string
  subtitle?: string
  address: string[]
  note?: string
  phone: string
  email: string
  hours: string[]
  mapsHref?: string
  mapsLabel?: string
  pageHref?: string
  pageLabel?: string
}

export interface LocalTeam {
  name: string
  sport: string
  area?: string
  logo?: string
  initials: string
  storeHref?: string
}

export interface TeamStore {
  name: string
  sport: string
  initials: string
  href: string
  logo?: string
}

export interface Brand {
  name: string
  logo?: string
}

export const navLinks = [
  { label: 'Home', href: '/' },
  { label: 'Gemini', href: '/gemini' },
  { label: 'About', href: '/#about' },
  { label: 'Our Team', href: '/#managers' },
  { label: 'Services', href: '/#services' },
  { label: 'Teamwear', href: '/#teamwear' },
  { label: 'Locations', href: '/#locations' },
  { label: 'Contact', href: '/#contact' },
] as const

export const managers: Person[] = [
  {
    initials: 'LF',
    name: 'Larry Ford',
    role: 'General Manager',
    location: "Oversees all Pete's Sports operations",
    email: 'lford@petessports.com',
    phone: '+1 (519) 520-9287',
    lead: true,
  },
  {
    initials: 'CS',
    name: 'Carsen Smith',
    role: 'Store Manager',
    location: "Pete's Main Store & Gemini — London & Strathroy",
    email: 'csmith@petessports.com',
  },
]

export const salesReps: Person[] = [
  { initials: 'AA', name: 'Art Ademi', role: 'Sales Representative', location: "Pete's Main Store — London" },
  { initials: 'BG', name: 'Brandon Glover', role: 'Assistant Manager', location: "Pete's Sports — London" },
  { initials: 'DA', name: 'Drin Ademi', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'JP', name: 'John Pearce', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'KL', name: 'Kaden Lange', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'QG', name: 'Quinn Gavin-White', role: 'Sales Representative', location: "Pete's Sports — London" },
]

export const staffInbox = {
  title: 'Ask the Staff',
  email: 'store@petessports.com',
  phone: '(519) 433-9555',
  description: 'For product details, inventory levels, pricing, and other in-store details — including general inquiries.',
} as const

export const geminiManagers: Person[] = [
  {
    initials: 'LF',
    name: 'Larry Ford',
    role: 'General Manager',
    location: "Oversees all Pete's Sports operations",
    email: 'lford@petessports.com',
    phone: '+1 (519) 520-9287',
    lead: true,
  },
  {
    initials: 'CS',
    name: 'Carsen Smith',
    role: 'Store Manager',
    location: 'Gemini Sportsplex Pro Shop — Strathroy',
    email: 'csmith@petessports.com',
  },
]

export const geminiSalesReps: Person[] = [
  { initials: 'MV', name: 'Mason Vandenburg', role: 'Sales Representative', location: 'Gemini Sportsplex Pro Shop — Strathroy' },
  { initials: 'OV', name: 'Owen Van Geffen', role: 'Sales Representative', location: 'Gemini Sportsplex Pro Shop — Strathroy' },
  { initials: 'QW', name: 'Quin Wardell', role: 'Sales Representative', location: 'Gemini Sportsplex Pro Shop — Strathroy' },
]

export const geminiHours = [
  { label: 'Monday – Friday', time: '3:00 PM – 9:00 PM' },
  { label: 'Saturday – Sunday', time: '8:00 AM – 6:00 PM' },
] as const

export const geminiLocalTeams: LocalTeam[] = [
  {
    name: 'Bluewater Hawks',
    sport: 'Hockey',
    area: 'Strathroy & area',
    logo: '/assets/bluewater-hawks-logo.png',
    initials: 'BH',
    storeHref: 'https://www.petessports.com/bluewater-hawks',
  },
  {
    name: 'Strathroy Royals',
    sport: 'Baseball',
    area: 'Strathroy',
    logo: '/assets/strathroy-royals-logo.png',
    initials: 'SR',
    storeHref: 'https://www.petessports.com/strathroy-royals-baseball',
  },
  {
    name: 'Strathroy Jr. Rockets',
    sport: 'Hockey',
    area: 'Strathroy',
    initials: 'JR',
    storeHref: 'https://www.petessports.com/strathroy-jr-rockets',
  },
  {
    name: 'North Middlesex Jr. Stars',
    sport: 'Hockey',
    area: 'Park Hill teams',
    initials: 'NS',
    logo: '/assets/north-middlesex-jr-stars-logo.png',
    storeHref: 'https://www.petessports.com/north-middlesex-jr-stars',
  },
]

export const services: Service[] = [
  {
    title: 'Sporting Equipment',
    description: 'Top quality hockey, baseball and more. We carry the best brands and help you find the right gear for your level.',
    link: '/shop/',
    linkLabel: 'Browse inventory',
  },
  {
    title: 'Custom Embroidery & Cresting',
    description: 'Professional in-house embroidery and cresting for teams, businesses, and individuals. High quality that lasts.',
    link: 'embroidery-order.html',
    linkLabel: 'Start an order form',
  },
  {
    title: 'Teamwear & Jerseys',
    description: 'Full team outfitting for hockey, baseball and more. Custom jerseys, apparel, and complete team stores.',
  },
  {
    title: 'Skate Sharpening & Repairs',
    description: 'Walk-in skate sharpening plus rivet and eyelet repairs. $10 per pair.',
    tag: '$10 per pair',
    link: '#sharpening',
    linkLabel: 'Sharpening details',
  },
  {
    title: 'Corporate & Workwear',
    description: 'Branded apparel for businesses — t-shirts, hoodies, jackets, caps and more. Contact us for a quote.',
  },
  {
    title: 'Team Stores',
    description: 'We set up and manage full team stores for associations and clubs. "You made the cut — get your team apparel here."',
    link: '#teamwear',
    linkLabel: 'Shop team stores',
  },
]

export const teamwearItems = [
  'Full custom jersey design & production',
  'Embroidery, screen printing & cresting',
  'Complete team stores for associations',
  'Fast turnaround on team orders',
] as const

export const teamStores: TeamStore[] = [
  {
    name: 'Bluewater Hawks',
    sport: 'Hockey',
    initials: 'BH',
    href: 'https://www.petessports.com/bluewater-hawks',
    logo: '/assets/bluewater-hawks-logo.png',
  },
  {
    name: 'North London Nationals',
    sport: 'Hockey',
    initials: 'NL',
    href: 'https://www.petessports.com/north-london-nationals',
    logo: '/assets/north-london-nationals-logo.png',
  },
  {
    name: 'Strathroy Royals',
    sport: 'Baseball',
    initials: 'SR',
    href: 'https://www.petessports.com/strathroy-royals-baseball',
    logo: '/assets/strathroy-royals-logo.png',
  },
]

export const localTeams = [
  'Bluewater Hawks',
  'Ilderton Jets',
  'Jr Mustangs',
  'London Dart League',
  'North London Nationals',
  'Oakridge Aeros',
  'Strathroy Jr. Rockets',
  'NL Diamonds',
  'Strathroy Royals',
  '+ many more local teams',
] as const

export const locations: Location[] = [
  {
    title: "Pete's Sports — London",
    address: ['900 Oxford Street East, Unit 15', 'London, ON N5Y 5A1'],
    phone: '(519) 433-9555',
    email: 'sales@petessports.com',
    hours: [
      'Monday – Friday: 10:00 AM – 6:00 PM',
      'Saturday: 10:00 AM – 4:00 PM',
      'Sunday: Closed',
    ],
    mapsHref: 'https://maps.google.com/?q=900+Oxford+Street+East+Unit+15+London+ON+N5Y+5A1',
    mapsLabel: 'Get directions',
  },
  {
    title: "Pete's Sports — Strathroy",
    subtitle: 'Gemini Sportsplex Pro Shop',
    address: ['667 Adair Blvd', 'Strathroy, ON N7G 3H8'],
    note: "Located inside the Gemini Sportsplex. Open 7 days a week — pop in while you're at the arena for hockey gear, equipment, and teamwear.",
    phone: '(519) 433-9555',
    email: 'sales@petessports.com',
    hours: [
      'Open 7 days a week',
      'Monday – Friday: 3:00 PM – 9:00 PM',
      'Saturday – Sunday: 8:00 AM – 6:00 PM',
    ],
    mapsHref: 'https://maps.google.com/?q=667+Adair+Blvd+Strathroy+ON+N7G+3H8',
    mapsLabel: 'Get directions',
    pageHref: '/gemini',
    pageLabel: 'Explore the Gemini Pro Shop',
  },
]

export const skateSharpening = {
  title: 'Skate Sharpening',
  price: '$10',
  priceLabel: 'per pair',
  intro: 'Walk in during store hours. Ask us which hollow is best for you.',
  points: [
    '$10 skate sharpening',
    'Rivet and eyelet repairs',
  ],
  cardsTitle: 'Bundle and Save',
  cardsIntro: 'Pick up a skate sharpening card in store and save on every visit.',
  cards: [
    { label: '5 pack', price: '$45', each: '$9 each' },
    { label: '10 pack', price: '$80', each: '$8 each' },
    { label: '20 pack', price: '$140', each: '$7 each' },
  ],
} as const

export const brandGroups: { label: string; brands: Brand[] }[] = [
  {
    label: 'Hockey',
    brands: [
      { name: 'Bauer', logo: '/assets/brands/bauer.svg' },
      { name: 'CCM', logo: '/assets/brands/ccm.svg' },
      { name: 'Warrior', logo: '/assets/brands/warrior.png' },
      { name: 'True' },
    ],
  },
  {
    label: 'Baseball',
    brands: [
      { name: 'Rawlings', logo: '/assets/brands/rawlings.png' },
      { name: 'Easton', logo: '/assets/brands/easton.svg' },
      { name: 'Mizuno', logo: '/assets/brands/mizuno.jpg' },
      { name: 'Worth' },
    ],
  },
  {
    label: 'Apparel',
    brands: [
      { name: 'Under Armour', logo: '/assets/brands/under-armour.svg' },
      { name: 'Bauer', logo: '/assets/brands/bauer.svg' },
      { name: 'CCM', logo: '/assets/brands/ccm.svg' },
    ],
  },
]

export const inquiries: Record<InquiryType, { email: string; name: string; subject: string; label: string }> = {
  store: {
    label: 'Store Inquiry',
    email: 'store@petessports.com',
    name: "Pete's Sports Store",
    subject: 'Store Inquiry',
  },
  sales: {
    label: 'Sales Inquiry',
    email: 'sales@petessports.com',
    name: 'Sales Team',
    subject: 'Sales Inquiry',
  },
  storeManager: {
    label: 'Store Manager',
    email: 'csmith@petessports.com',
    name: 'Carsen Smith — Store Manager',
    subject: 'Store Manager Inquiry',
  },
  manager: {
    label: 'General Manager',
    email: 'lford@petessports.com',
    name: 'Larry Ford — General Manager',
    subject: 'General Manager Inquiry',
  },
}