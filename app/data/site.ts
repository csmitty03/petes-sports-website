export type InquiryType = 'sales' | 'store' | 'manager'

export interface Person {
  initials: string
  name: string
  role: string
  location: string
  email?: string
  lead?: boolean
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
}

export const navLinks = [
  { label: 'Shop', href: '/shop' },
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
  { initials: 'BG', name: 'Brandon Glover', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'DA', name: 'Drin Ademi', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'JP', name: 'John Pearce', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'KL', name: 'Kaden Lange', role: 'Sales Representative', location: "Pete's Sports — London" },
  { initials: 'QG', name: 'Quinn Gavin-White', role: 'Sales Representative', location: "Pete's Sports — London" },
]

export const services: Service[] = [
  {
    title: 'Sporting Equipment',
    description: 'Top quality hockey, baseball and more. We carry the best brands and help you find the right gear for your level.',
    link: '/shop',
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
    description: 'High quality skate sharpening plus rivet and eyelet repairs to keep your skates performing at their best.',
    tag: 'Sharpening • Rivets • Eyelets',
  },
  {
    title: 'Corporate & Workwear',
    description: 'Branded apparel for businesses — t-shirts, hoodies, jackets, caps and more. Contact us for a quote.',
  },
  {
    title: 'Team Stores',
    description: 'We set up and manage full team stores for associations and clubs. "You made the cut — get your team apparel here."',
    link: '#contact',
  },
]

export const teamwearItems = [
  'Full custom jersey design & production',
  'Embroidery, screen printing & cresting',
  'Complete team stores for associations',
  'Fast turnaround on team orders',
] as const

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
  },
  {
    title: "Pete's Sports — Strathroy",
    subtitle: 'Gemini Sportsplex Pro Shop',
    address: ['667 Adair Blvd', 'Strathroy, ON N7G 3H8'],
    note: "Located inside the Gemini Sportsplex. Pop in while you're at the arena for hockey gear, equipment, and teamwear.",
    phone: '(519) 433-9555',
    email: 'sales@petessports.com',
    hours: [
      'Open during Gemini Sportsplex arena hours.',
      'Call ahead to confirm availability.',
    ],
  },
]

export const inquiries: Record<InquiryType, { email: string; name: string; subject: string; label: string }> = {
  sales: {
    label: 'Sales Inquiry',
    email: 'sales@petessports.com',
    name: 'Sales Team',
    subject: 'Sales Inquiry',
  },
  store: {
    label: 'Store Inquiry',
    email: 'csmith@petessports.com',
    name: 'Carsen Smith — Store Manager',
    subject: 'Store Inquiry',
  },
  manager: {
    label: 'General Manager',
    email: 'lford@petessports.com',
    name: 'Larry Ford — General Manager',
    subject: 'General Manager Inquiry',
  },
}