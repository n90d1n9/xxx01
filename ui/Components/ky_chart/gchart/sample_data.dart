List series1 = [
  {
    "name": "data satu",
    "data": [5, 230, 224, 218, 135, 147, 260],
    "type": "line"
  },
  {
    "name": "data dua",
    "data": [50, 230, 124, 218, 55, 87, 160],
    "type": "line"
  }
];

Map config1 = {
  "maxY": 5,
  'tooltip': {
    'trigger': 'axis',
    'axisPointer': {
      'type': 'cross',
      'label': {'backgroundColor': '#6a7985'}
    }
  },
  "xAxis": {
    "type": "category",
    "data": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  },
  "yAxis": {"type": "value"},
  "series": series1
};

Map config2 = {
  'title': {'text': 'Stacked Area Chart'},
  'tooltip': {
    'trigger': 'axis',
    'axisPointer': {
      'type': 'cross',
      'label': {'backgroundColor': '#6a7985'}
    }
  },
  'legend': {
    'data': ['Email', 'Union Ads', 'Video Ads', 'Direct', 'Search Engine']
  },
  'toolbox': {
    'feature': {'saveAsImage': {}}
  },
  'grid': {'left': '3%', 'right': '4%', 'bottom': '3%', 'containLabel': true},
  'xAxis': {
    'type': 'category',
    'boundaryGap': false,
    'data': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
  },
  'yAxis': [
    {'type': 'value'}
  ],
  'series': [
    {
      'name': 'Email',
      'type': 'line',
      'stack': 'Total',
      'areaStyle': {},
      'emphasis': {'focus': 'series'},
      'data': [120, 132, 101, 134, 90, 230, 210]
    },
    {
      'name': 'Union Ads',
      'type': 'line',
      'stack': 'Total',
      'areaStyle': {},
      'emphasis': {'focus': 'series'},
      'data': [220, 182, 191, 234, 290, 330, 310]
    },
    {
      'name': 'Video Ads',
      'type': 'line',
      'stack': 'Total',
      'areaStyle': {},
      'emphasis': {'focus': 'series'},
      'data': [150, 232, 201, 154, 190, 330, 410]
    },
    {
      'name': 'Direct',
      'type': 'line',
      'stack': 'Total',
      'areaStyle': {},
      'emphasis': {'focus': 'series'},
      'data': [320, 332, 301, 334, 390, 330, 320]
    },
    {
      'name': 'Search Engine',
      'type': 'line',
      'stack': 'Total',
      'label': {'show': true, 'position': 'top'},
      'areaStyle': {},
      'emphasis': {'focus': 'series'},
      'data': [820, 932, 901, 934, 1290, 1330, 1320]
    }
  ]
};

Map config3 = {
  "type": "line",
  "title": {"text": "Temperature Change in the Coming Week"},
  "tooltip": {"trigger": "axis"},
  "legend": {},
  "toolbox": {
    "show": true,
    "feature": {
      "dataZoom": {"yAxisIndex": "none"},
      "dataView": {"readOnly": false},
      "magicType": {
        "type": ["line", "bar"]
      },
      "restore": {},
      "saveAsImage": {}
    }
  },
  "xAxis": {
    "type": "category",
    "boundaryGap": false,
    "data": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  },
  "yAxis": {
    "type": "value",
    "axisLabel": {"formatter": "{value} °C"}
  },
  "series": [
    {
      "name": "Highest",
      "type": "line",
      "data": [10, 11, 13, 11, 12, 12, 9],
      "markPoint": {
        "data": [
          {"type": "max", "name": "Max"},
          {"type": "min", "name": "Min"}
        ]
      },
      "markLine": {
        "data": [
          {"type": "average", "name": "Avg"}
        ]
      }
    },
    {
      "name": "Lowest",
      "type": "line",
      "data": [1, -2, 2, 5, 3, 2, 0],
      "markPoint": {
        "data": [
          {"name": "周最低", "value": -2, "xAxis": 1, "yAxis": -1.5}
        ]
      },
      "markLine": {
        "data": [
          {"type": "average", "name": "Avg"},
          [
            {"symbol": "none", "x": "90%", "yAxis": "max"},
            {
              "symbol": "circle",
              "label": {"position": "start", "formatter": "Max"},
              "type": "max",
              "name": "最高点"
            }
          ]
        ]
      }
    }
  ]
};

Map config4 = {
  "type": "line",
  "color": ["#80FFA5", "#00DDFF", "#37A2FF", "#FF0087", "#FFBF00"],
  "title": {"text": "Gradient Stacked Area Chart"},
  "tooltip": {
    "trigger": "axis",
    "axisPointer": {
      "type": "cross",
      "label": {"backgroundColor": "#6a7985"}
    }
  },
  "legend": {
    "data": ["Line 1", "Line 2", "Line 3", "Line 4", "Line 5"]
  },
  "toolbox": {
    "feature": {"saveAsImage": {}}
  },
  "grid": {"left": "3%", "right": "4%", "bottom": "3%", "containLabel": true},
  "xAxis": [
    {
      "type": "category",
      "boundaryGap": false,
      "data": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }
  ],
  "yAxis": [
    {"type": "value"}
  ],
  "series": [
    {
      "name": "Line 1",
      "type": "line",
      "stack": "Total",
      "smooth": true,
      "lineStyle": {"width": 0},
      "showSymbol": false,
      "areaStyle": {"opacity": 0.8},
      "emphasis": {"focus": "series"},
      "data": [140, 232, 101, 264, 90, 340, 250]
    },
    {
      "name": "Line 2",
      "type": "line",
      "stack": "Total",
      "smooth": true,
      "lineStyle": {"width": 0},
      "showSymbol": false,
      "areaStyle": {"opacity": 0.8},
      "emphasis": {"focus": "series"},
      "data": [120, 282, 111, 234, 220, 340, 310]
    },
    {
      "name": "Line 3",
      "type": "line",
      "stack": "Total",
      "smooth": true,
      "lineStyle": {"width": 0},
      "showSymbol": false,
      "areaStyle": {"opacity": 0.8},
      "emphasis": {"focus": "series"},
      "data": [320, 132, 201, 334, 190, 130, 220]
    },
    {
      "name": "Line 4",
      "type": "line",
      "stack": "Total",
      "smooth": true,
      "lineStyle": {"width": 0},
      "showSymbol": false,
      "areaStyle": {"opacity": 0.8},
      "emphasis": {"focus": "series"},
      "data": [220, 402, 231, 134, 190, 230, 120]
    },
    {
      "name": "Line 5",
      "type": "line",
      "stack": "Total",
      "smooth": true,
      "lineStyle": {"width": 0},
      "showSymbol": false,
      "label": {"show": true, "position": "top"},
      "areaStyle": {"opacity": 0.8},
      "emphasis": {"focus": "series"},
      "data": [220, 302, 181, 234, 210, 290, 150]
    }
  ]
};

Map config5 = {
  "xAxis": {
    "type": "category",
    "boundaryGap": false,
    "data": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  },
  "yAxis": {"type": "value"},
  "series": [
    {
      "data": [820, 932, 901, 934, 1290, 1330, 1320],
      "type": "line",
      "areaStyle": {}
    }
  ]
};
