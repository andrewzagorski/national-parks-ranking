export interface RubricItem {
  score: number
  description: string
}

export type Rubric = Record<string, RubricItem[]>

const rubric: Rubric = {
  landscape_beauty: [
    {
      score: 1,
      description: 'Scenery is ordinary or uninspiring'
    },
    { score: 3, description: 'Pretty and enjoyable to look at' },
    {
      score: 5,
      description:
        'Jaw-dropping vistas; paradise for photographers and nature lovers'
    }
  ],
  uniqueness: [
    {
      score: 1,
      description: 'Identical experience available in multiple regions'
    },
    {
      score: 3,
      description: 'Some unique features but shares traits with other parks'
    },
    { score: 5, description: 'Completely one-of-a-kind; nothing else like it' }
  ],
  wow_moments: [
    { score: 1, description: 'Nothing that stood out or inspired awe' },
    { score: 3, description: 'A few memorable moments' },
    { score: 5, description: 'Multiple iconic, unforgettable scenes' }
  ],
  crowds: [
    { score: 1, description: 'Flooded with people every single day' },
    { score: 3, description: 'Busy at peak hours but manageable' },
    { score: 5, description: 'Rarely feels crowded; easy to find solitude' }
  ],
  wildlife: [
    { score: 1, description: 'Wildlife is nonexistent or uninteresting' },
    { score: 3, description: 'Opportunity to see some unique critters' },
    { score: 5, description: 'Abundant, diverse animals throughout the park' }
  ],
  variety: [
    { score: 1, description: 'One-note; one landscape/activity dominates' },
    { score: 3, description: 'Some different activities and landscapes' },
    {
      score: 5,
      description:
        'Water, geology, culture, wildlife, etc.; varied experiences in the front-country and back-country'
    }
  ],
  selection: [
    { score: 1, description: 'All options exhausted in a single day' },
    {
      score: 3,
      description:
        'Multiple options for everyone; warrants multiple visits for multiple days at a time'
    },
    {
      score: 5,
      description: 'All visitors could easily spend a full week or more'
    }
  ],
  access: [
    { score: 1, description: 'Extremely remote and costly to experience' },
    { score: 3, description: 'Longer drive required; limited by seasons' },
    {
      score: 5,
      description: 'Major airport nearby; short easy drive year-round'
    }
  ]
}

export default rubric
