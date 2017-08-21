local JDatetime = require "JDatetime"
local
_M = {}

--#========角度变换===============
local rad = 180 * 3600 / math.pi  --# 每弧度的角秒数
local RAD = 180 / math.pi         --# 每弧度的角度数

--# 对超过0-2PI的角度转为0-2PI
function _M.rad2mrad(v)
    local value = v % (2 * math.pi)
    if value < 0 then
        return value + 2*math.pi
    end
    return value
end

function _M.rad2rrad(v)
    local value = v % (2 * math.pi)
    if (value - 0.0) <= -math.pi then
        return value + 2*math.pi
    end
    if (value - 0.0) > math.pi then
        return value - 2*math.pi
    end

    return value
end

local XL00 = {10000000000,
20,578,920,1100,1124,1136,1148,1217,1226,1229,1229,1229,1229,1937,2363,2618,2633,2660,2666,
  17534704567,0.00000000000,0.00000000000,334165646,4.669256804,6283.075849991,3489428,4.6261024,12566.1517000,349706,2.744118,5753.384885,341757,2.828866,3.523118,313590,3.627670,77713.771468,267622,4.418084,7860.419392,234269,6.135162,3930.209696,132429,0.742464,11506.769770,127317,2.037097,529.690965,119917,1.109629,1577.343542,99025,5.23268,5884.92685,90186,2.04505,26.29832,85722,3.50849,398.14900,77979,1.17883,5223.69392,75314,2.53339,5507.55324,50526,4.58293,18849.22755,49238,4.20507,775.52261,35666,2.91954,0.06731,31709,5.84902,11790.62909,28413,1.89869,796.29801,27104,0.31489,10977.07880,24281,0.34481,5486.77784,20616,4.80647,2544.31442,20539,1.86948,5573.14280,20226,2.45768,6069.77675,15552,0.83306,213.29910,13221,3.41118,2942.46342,12618,1.08303,20.77540,11513,0.64545,0.98032,10285,0.63600,4694.00295,10190,0.97569,15720.83878,10172,4.26680,7.11355,9921,6.2099,2146.1654,9761,0.6810,155.4204,8580,5.9832,161000.6857,8513,1.2987,6275.9623,8471,3.6708,71430.6956,7964,1.8079,17260.1547,7876,3.0370,12036.4607,7465,1.7551,5088.6288,7387,3.5032,3154.6871,7355,4.6793,801.8209,6963,0.8330,9437.7629,6245,3.9776,8827.3903,6115,1.8184,7084.8968,5696,2.7843,6286.5990,5612,4.3869,14143.4952,5558,3.4701,6279.5527,5199,0.1891,12139.5535,5161,1.3328,1748.0164,5115,0.2831,5856.4777,4900,0.4874,1194.4470,4104,5.3682,8429.2413,4094,2.3985,19651.0485,3920,6.1683,10447.3878,3677,6.0413,10213.2855,3660,2.5696,1059.3819,3595,1.7088,2352.8662,3557,1.7760,6812.7668,3329,0.5931,17789.8456,3041,0.4429,83996.8473,3005,2.7398,1349.8674,2535,3.1647,4690.4798,2474,0.2148,3.5904,2366,0.4847,8031.0923,2357,2.0653,3340.6124,2282,5.2220,4705.7323,2189,5.5559,553.5694,2142,1.4256,16730.4637,2109,4.1483,951.7184,2030,0.3713,283.8593,1992,5.2221,12168.0027,1986,5.7747,6309.3742,1912,3.8222,23581.2582,1889,5.3863,149854.4001,1790,2.2149,13367.9726,1748,4.5605,135.0651,1622,5.9884,11769.8537,1508,4.1957,6256.7775,1442,4.1932,242.7286,1435,3.7236,38.0277,1397,4.4014,6681.2249,1362,1.8893,7632.9433,1250,1.1305,5.5229,1205,2.6223,955.5997,1200,1.0035,632.7837,1129,0.1774,4164.3120,1083,0.3273,103.0928,1052,0.9387,11926.2544,1050,5.3591,1592.5960,1033,6.1998,6438.4962,1001,6.0291,5746.2713,980,0.999,11371.705,980,5.244,27511.468,938,2.624,5760.498,923,0.483,522.577,922,4.571,4292.331,905,5.337,6386.169,862,4.165,7058.598,841,3.299,7234.794,836,4.539,25132.303,813,6.112,4732.031,812,6.271,426.598,801,5.821,28.449,787,0.996,5643.179,776,2.957,23013.540,769,3.121,7238.676,758,3.974,11499.656,735,4.386,316.392,731,0.607,11513.883,719,3.998,74.782,706,0.323,263.084,676,5.911,90955.552,663,3.665,17298.182,653,5.791,18073.705,630,4.717,6836.645,615,1.458,233141.314,612,1.075,19804.827,596,3.321,6283.009,596,2.876,6283.143,555,2.452,12352.853,541,5.392,419.485,531,0.382,31441.678,519,4.065,6208.294,513,2.361,10973.556,494,5.737,9917.697,450,3.272,11015.106,449,3.653,206.186,447,2.064,7079.374,435,4.423,5216.580,421,1.906,245.832,413,0.921,3738.761,402,0.840,20.355,387,1.826,11856.219,379,2.344,3.881,374,2.954,3128.389,370,5.031,536.805,365,1.018,16200.773,365,1.083,88860.057,352,5.978,3894.182,352,2.056,244287.600,351,3.713,6290.189,340,1.106,14712.317,339,0.978,8635.942,339,3.202,5120.601,333,0.837,6496.375,325,3.479,6133.513,316,5.089,21228.392,316,1.328,10873.986,309,3.646,10.637,303,1.802,35371.887,296,3.397,9225.539,288,6.026,154717.610,281,2.585,14314.168,262,3.856,266.607,262,2.579,22483.849,257,1.561,23543.231,255,3.949,1990.745,251,3.744,10575.407,240,1.161,10984.192,238,0.106,7.046,236,4.272,6040.347,234,3.577,10969.965,211,3.714,65147.620,210,0.754,13521.751,207,4.228,5650.292,202,0.814,170.673,201,4.629,6037.244,200,0.381,6172.870,199,3.933,6206.810,199,5.197,6262.300,197,1.046,18209.330,195,1.070,5230.807,195,4.869,36.028,194,4.313,6244.943,192,1.229,709.933,192,5.595,6282.096,192,0.602,6284.056,189,3.744,23.878,188,1.904,15.252,188,0.867,22003.915,182,3.681,15110.466,181,0.491,1.484,179,3.222,39302.097,179,1.259,12559.038,
  62833196674749,0.000000000000,0.000000000000,20605886,2.67823456,6283.07584999,430343,2.635127,12566.151700,42526,1.59047,3.52312,11926,5.79557,26.29832,10898,2.96618,1577.34354,9348,2.5921,18849.2275,7212,1.1385,529.6910,6777,1.8747,398.1490,6733,4.4092,5507.5532,5903,2.8880,5223.6939,5598,2.1747,155.4204,4541,0.3980,796.2980,3637,0.4662,775.5226,2896,2.6471,7.1135,2084,5.3414,0.9803,1910,1.8463,5486.7778,1851,4.9686,213.2991,1729,2.9912,6275.9623,1623,0.0322,2544.3144,1583,1.4305,2146.1654,1462,1.2053,10977.0788,1246,2.8343,1748.0164,1188,3.2580,5088.6288,1181,5.2738,1194.4470,1151,2.0750,4694.0030,1064,0.7661,553.5694,997,1.303,6286.599,972,4.239,1349.867,945,2.700,242.729,858,5.645,951.718,758,5.301,2352.866,639,2.650,9437.763,610,4.666,4690.480,583,1.766,1059.382,531,0.909,3154.687,522,5.661,71430.696,520,1.854,801.821,504,1.425,6438.496,433,0.241,6812.767,426,0.774,10447.388,413,5.240,7084.897,374,2.001,8031.092,356,2.429,14143.495,350,4.800,6279.553,337,0.888,12036.461,337,3.862,1592.596,325,3.400,7632.943,322,0.616,8429.241,318,3.188,4705.732,297,6.070,4292.331,295,1.431,5746.271,290,2.325,20.355,275,0.935,5760.498,270,4.804,7234.794,253,6.223,6836.645,228,5.003,17789.846,225,5.672,11499.656,215,5.202,11513.883,208,3.955,10213.286,208,2.268,522.577,206,2.224,5856.478,206,2.550,25132.303,203,0.910,6256.778,189,0.532,3340.612,188,4.735,83996.847,179,1.474,4164.312,178,3.025,5.523,177,3.026,5753.385,159,4.637,3.286,157,6.124,5216.580,155,3.077,6681.225,154,4.200,13367.973,143,1.191,3894.182,138,3.093,135.065,136,4.245,426.598,134,5.765,6040.347,128,3.085,5643.179,127,2.092,6290.189,125,3.077,11926.254,125,3.445,536.805,114,3.244,12168.003,112,2.318,16730.464,111,3.901,11506.770,111,5.320,23.878,105,3.750,7860.419,103,2.447,1990.745,96,0.82,3.88,96,4.08,6127.66,91,5.42,206.19,91,0.42,7079.37,88,5.17,11790.63,81,0.34,9917.70,80,3.89,10973.56,78,2.40,1589.07,78,2.58,11371.70,77,3.98,955.60,77,3.36,36.03,76,1.30,103.09,75,5.18,10969.97,75,4.96,6496.37,73,5.21,38.03,72,2.65,6309.37,70,5.61,3738.76,69,2.60,3496.03,69,0.39,15.25,69,2.78,20.78,65,1.13,7058.60,64,4.28,28.45,61,5.63,10984.19,60,0.73,419.48,60,5.28,10575.41,58,5.55,17298.18,58,3.19,4732.03,
  5291887,0.0000000,0.0000000,871984,1.072097,6283.075850,30913,0.86729,12566.15170,2734,0.0530,3.5231,1633,5.1883,26.2983,1575,3.6846,155.4204,954,0.757,18849.228,894,2.057,77713.771,695,0.827,775.523,506,4.663,1577.344,406,1.031,7.114,381,3.441,5573.143,346,5.141,796.298,317,6.053,5507.553,302,1.192,242.729,289,6.117,529.691,271,0.306,398.149,254,2.280,553.569,237,4.381,5223.694,208,3.754,0.980,168,0.902,951.718,153,5.759,1349.867,145,4.364,1748.016,134,3.721,1194.447,125,2.948,6438.496,122,2.973,2146.165,110,1.271,161000.686,104,0.604,3154.687,100,5.986,6286.599,92,4.80,5088.63,89,5.23,7084.90,83,3.31,213.30,76,3.42,5486.78,71,6.19,4690.48,68,3.43,4694.00,65,1.60,2544.31,64,1.98,801.82,61,2.48,10977.08,50,1.44,6836.65,49,2.34,1592.60,46,1.31,4292.33,46,3.81,149854.40,43,0.04,7234.79,40,4.94,7632.94,39,1.57,71430.70,38,3.17,6309.37,35,0.99,6040.35,35,0.67,1059.38,31,3.18,2352.87,31,3.55,8031.09,30,1.92,10447.39,30,2.52,6127.66,28,4.42,9437.76,28,2.71,3894.18,27,0.67,25132.30,26,5.27,6812.77,25,0.55,6279.55,23,1.38,4705.73,22,0.64,6256.78,20,6.07,640.88,
  28923,5.84384,6283.07585,3496,0.0000,0.0000,1682,5.4877,12566.1517,296,5.196,155.420,129,4.722,3.523,71,5.30,18849.23,64,5.97,242.73,40,3.79,553.57,
  11408,3.14159,0.00000,772,4.134,6283.076,77,3.84,12566.15,42,0.42,155.42,
  88,3.14,0.00,17,2.77,6283.08,5,2.01,155.42,3,2.21,12566.15,
  27962,3.19870,84334.66158,10164,5.42249,5507.55324,8045,3.8801,5223.6939,4381,3.7044,2352.8662,3193,4.0003,1577.3435,2272,3.9847,1047.7473,1814,4.9837,6283.0758,1639,3.5646,5856.4777,1444,3.7028,9437.7629,1430,3.4112,10213.2855,1125,4.8282,14143.4952,1090,2.0857,6812.7668,1037,4.0566,71092.8814,971,3.473,4694.003,915,1.142,6620.890,878,4.440,5753.385,837,4.993,7084.897,770,5.554,167621.576,719,3.602,529.691,692,4.326,6275.962,558,4.410,7860.419,529,2.484,4705.732,521,6.250,18073.705,
  903,3.897,5507.553,618,1.730,5223.694,380,5.244,2352.866,
  166,1.627,84334.662,
  10001398880,0.00000000000,0.00000000000,167069963,3.098463508,6283.075849991,1395602,3.0552461,12566.1517000,308372,5.198467,77713.771468,162846,1.173877,5753.384885,157557,2.846852,7860.419392,92480,5.45292,11506.76977,54244,4.56409,3930.20970,47211,3.66100,5884.92685,34598,0.96369,5507.55324,32878,5.89984,5223.69392,30678,0.29867,5573.14280,24319,4.27350,11790.62909,21183,5.84715,1577.34354,18575,5.02194,10977.07880,17484,3.01194,18849.22755,10984,5.05511,5486.77784,9832,0.8868,6069.7768,8650,5.6896,15720.8388,8583,1.2708,161000.6857,6490,0.2725,17260.1547,6292,0.9218,529.6910,5706,2.0137,83996.8473,5574,5.2416,71430.6956,4938,3.2450,2544.3144,4696,2.5781,775.5226,4466,5.5372,9437.7629,4252,6.0111,6275.9623,3897,5.3607,4694.0030,3825,2.3926,8827.3903,3749,0.8295,19651.0485,3696,4.9011,12139.5535,3566,1.6747,12036.4607,3454,1.8427,2942.4634,3319,0.2437,7084.8968,3192,0.1837,5088.6288,3185,1.7778,398.1490,2846,1.2134,6286.5990,2779,1.8993,6279.5527,2628,4.5890,10447.3878,2460,3.7866,8429.2413,2393,4.9960,5856.4777,2359,0.2687,796.2980,2329,2.8078,14143.4952,2210,1.9500,3154.6871,2035,4.6527,2146.1654,1951,5.3823,2352.8662,1883,0.6731,149854.4001,1833,2.2535,23581.2582,1796,0.1987,6812.7668,1731,6.1520,16730.4637,1717,4.4332,10213.2855,1619,5.2316,17789.8456,1381,5.1896,8031.0923,1364,3.6852,4705.7323,1314,0.6529,13367.9726,1041,4.3329,11769.8537,1017,1.5939,4690.4798,998,4.201,6309.374,966,3.676,27511.468,874,6.064,1748.016,779,3.674,12168.003,771,0.312,7632.943,756,2.626,6256.778,746,5.648,11926.254,693,2.924,6681.225,680,1.423,23013.540,674,0.563,3340.612,663,5.661,11371.705,659,3.136,801.821,648,2.650,19804.827,615,3.029,233141.314,612,5.134,1194.447,563,4.341,90955.552,552,2.091,17298.182,534,5.100,31441.678,531,2.407,11499.656,523,4.624,6438.496,513,5.324,11513.883,477,0.256,11856.219,461,1.722,7234.794,458,3.766,6386.169,458,4.466,5746.271,423,1.055,5760.498,422,1.557,7238.676,415,2.599,7058.598,401,3.030,1059.382,397,1.201,1349.867,379,4.907,4164.312,360,5.707,5643.179,352,3.626,244287.600,348,0.761,10973.556,342,3.001,4292.331,336,4.546,4732.031,334,3.138,6836.645,324,4.164,9917.697,316,1.691,11015.106,307,0.238,35371.887,298,1.306,6283.143,298,1.750,6283.009,293,5.738,16200.773,286,5.928,14712.317,281,3.515,21228.392,280,5.663,8635.942,277,0.513,26.298,268,4.207,18073.705,266,0.900,12352.853,260,2.962,25132.303,255,2.477,6208.294,242,2.800,709.933,231,1.054,22483.849,229,1.070,14314.168,216,1.314,154717.610,215,6.038,10873.986,200,0.561,7079.374,198,2.614,951.718,197,4.369,167283.762,186,2.861,5216.580,183,1.660,39302.097,183,5.912,3738.761,175,2.145,6290.189,173,2.168,10575.407,171,3.702,1592.596,171,1.343,3128.389,164,5.550,6496.375,164,5.856,10984.192,161,1.998,10969.965,161,1.909,6133.513,157,4.955,25158.602,154,6.216,23543.231,153,5.357,13521.751,150,5.770,18209.330,150,5.439,155.420,139,1.778,9225.539,139,1.626,5120.601,128,2.460,13916.019,123,0.717,143571.324,122,2.654,88860.057,121,4.414,3894.182,121,1.192,3.523,120,4.030,553.569,119,1.513,17654.781,117,3.117,14945.316,113,2.698,6040.347,110,3.085,43232.307,109,0.998,955.600,108,2.939,17256.632,107,5.285,65147.620,103,0.139,11712.955,103,5.850,213.299,102,3.046,6037.244,101,2.842,8662.240,100,3.626,6262.300,98,2.36,6206.81,98,5.11,6172.87,98,2.00,15110.47,97,2.67,5650.29,97,2.75,6244.94,96,4.02,6282.10,96,5.31,6284.06,92,0.10,29088.81,85,3.26,20426.57,84,2.60,28766.92,81,3.58,10177.26,80,5.81,5230.81,78,2.53,16496.36,77,4.06,6127.66,73,0.04,5481.25,72,5.96,12559.04,72,5.92,4136.91,71,5.49,22003.91,70,3.41,7.11,69,0.62,11403.68,69,3.90,1589.07,69,1.96,12416.59,69,4.51,426.60,67,1.61,11087.29,66,4.50,47162.52,66,5.08,283.86,66,4.32,16858.48,65,1.04,6062.66,64,1.59,18319.54,63,5.70,45892.73,63,4.60,66567.49,63,3.82,13517.87,62,2.62,11190.38,61,1.54,33019.02,60,5.58,10344.30,60,5.38,316428.23,60,5.78,632.78,59,6.12,9623.69,57,0.16,17267.27,57,3.86,6076.89,57,1.98,7668.64,56,4.78,20199.09,55,4.56,18875.53,55,3.51,17253.04,54,3.07,226858.24,54,4.83,18422.63,53,5.02,12132.44,52,3.63,5333.90,52,0.97,155427.54,51,3.36,20597.24,50,0.99,11609.86,50,2.21,1990.75,48,1.62,12146.67,48,1.17,12569.67,47,4.62,5436.99,47,1.81,12562.63,47,0.59,21954.16,47,0.76,7342.46,46,0.27,4590.91,46,3.77,156137.48,45,5.66,10454.50,44,5.84,3496.03,43,0.24,17996.03,41,5.93,51092.73,41,4.21,12592.45,40,5.14,1551.05,40,5.28,15671.08,39,3.69,18052.93,39,4.94,24356.78,38,2.72,11933.37,38,5.23,7477.52,38,4.99,9779.11,37,3.70,9388.01,37,4.44,4535.06,36,2.16,28237.23,36,2.54,242.73,36,0.22,5429.88,35,6.15,19800.95,35,2.92,36949.23,34,5.63,2379.16,34,5.73,16460.33,34,5.11,5849.36,33,6.19,6268.85,
        10301861,1.10748970,6283.07584999,172124,1.064423,12566.151700,70222,3.14159,0.00000,3235,1.0217,18849.2275,3080,2.8435,5507.5532,2497,1.3191,5223.6939,1849,1.4243,1577.3435,1008,5.9138,10977.0788,865,1.420,6275.962,863,0.271,5486.778,507,1.686,5088.629,499,6.014,6286.599,467,5.987,529.691,440,0.518,4694.003,410,1.084,9437.763,387,4.750,2544.314,375,5.071,796.298,352,0.023,83996.847,344,0.949,71430.696,341,5.412,775.523,322,6.156,2146.165,286,5.484,10447.388,284,3.420,2352.866,255,6.132,6438.496,252,0.243,398.149,243,3.092,4690.480,225,3.689,7084.897,220,4.952,6812.767,219,0.420,8031.092,209,1.282,1748.016,193,5.314,8429.241,185,1.820,7632.943,175,3.229,6279.553,173,1.537,4705.732,158,4.097,11499.656,158,5.539,3154.687,150,3.633,11513.883,148,3.222,7234.794,147,3.653,1194.447,144,0.817,14143.495,135,6.151,5746.271,134,4.644,6836.645,128,2.693,1349.867,123,5.650,5760.498,118,2.577,13367.973,113,3.357,17789.846,110,4.497,4292.331,108,5.828,12036.461,102,5.621,6256.778,99,1.14,1059.38,98,0.66,5856.48,93,2.32,10213.29,92,0.77,16730.46,88,1.50,11926.25,86,1.42,5753.38,85,0.66,155.42,81,1.64,6681.22,80,4.11,951.72,66,4.55,5216.58,65,0.98,25132.30,64,4.19,6040.35,64,0.52,6290.19,63,1.51,5643.18,59,6.18,4164.31,57,2.30,10973.56,55,2.32,11506.77,55,2.20,1592.60,55,5.27,3340.61,54,5.54,553.57,53,5.04,9917.70,53,0.92,11371.70,52,3.98,17298.18,52,3.60,10969.97,49,5.91,3894.18,49,2.51,6127.66,48,1.67,12168.00,46,0.31,801.82,42,3.70,10575.41,42,4.05,10984.19,40,2.17,7860.42,40,4.17,26.30,38,5.82,7058.60,37,3.39,6496.37,36,1.08,6309.37,36,5.34,7079.37,34,3.62,11790.63,32,0.32,16200.77,31,4.24,3738.76,29,4.55,11856.22,29,1.26,8635.94,27,3.45,5884.93,26,5.08,10177.26,26,5.38,21228.39,24,2.26,11712.96,24,1.05,242.73,24,5.59,6069.78,23,3.63,6284.06,23,1.64,4732.03,22,3.46,213.30,21,1.05,3496.03,21,3.92,13916.02,21,4.01,5230.81,20,5.16,12352.85,20,0.69,1990.75,19,2.73,6062.66,19,5.01,11015.11,18,6.04,6283.01,18,2.85,7238.68,18,5.60,6283.14,18,5.16,17253.04,18,2.54,14314.17,17,1.58,7.11,17,0.98,3930.21,17,4.75,17267.27,16,2.19,6076.89,16,2.19,18073.70,16,6.12,3.52,16,4.61,9623.69,16,3.40,16496.36,15,0.19,9779.11,15,5.30,13517.87,15,4.26,3128.39,15,0.81,709.93,14,0.50,25158.60,14,4.38,4136.91,13,0.98,65147.62,13,3.31,154717.61,13,2.11,1589.07,13,1.92,22483.85,12,6.03,9225.54,12,1.53,12559.04,12,5.82,6282.10,12,5.61,5642.20,12,2.38,167283.76,12,0.39,12132.44,12,3.98,4686.89,12,5.81,12569.67,12,0.56,5849.36,11,0.45,6172.87,11,5.80,16858.48,11,6.22,12146.67,11,2.27,5429.88,
       435939,5.784551,6283.075850,12363,5.57935,12566.15170,1234,3.1416,0.0000,879,3.628,77713.771,569,1.870,5573.143,330,5.470,18849.228,147,4.480,5507.553,110,2.842,161000.686,101,2.815,5223.694,85,3.11,1577.34,65,5.47,775.52,61,1.38,6438.50,50,4.42,6286.60,47,3.66,7084.90,46,5.39,149854.40,42,0.90,10977.08,40,3.20,5088.63,35,1.81,5486.78,32,5.35,3154.69,30,3.52,796.30,29,4.62,4690.48,28,1.84,4694.00,27,3.14,71430.70,27,6.17,6836.65,26,1.42,2146.17,25,2.81,1748.02,24,2.18,155.42,23,4.76,7234.79,21,3.38,7632.94,21,0.22,4705.73,20,4.22,1349.87,20,2.01,1194.45,20,4.58,529.69,19,1.59,6309.37,18,5.70,6040.35,18,6.03,4292.33,17,2.90,9437.76,17,2.00,8031.09,17,5.78,83996.85,16,0.05,2544.31,15,0.95,6127.66,14,0.36,10447.39,14,1.48,2352.87,13,0.77,553.57,13,5.48,951.72,13,5.27,6279.55,13,3.76,6812.77,11,5.41,6256.78,10,0.68,1592.60,10,4.95,398.15,10,1.15,3894.18,10,5.20,244287.60,10,1.94,11856.22,9,5.39,25132.30,8,6.18,1059.38,8,0.69,8429.24,8,5.85,242.73,7,5.26,14143.50,7,0.52,801.82,6,2.24,8635.94,6,4.00,13367.97,6,2.77,90955.55,6,5.17,7058.60,5,1.46,233141.31,5,4.13,7860.42,5,3.91,26.30,5,3.89,12036.46,5,5.58,6290.19,5,5.54,1990.75,5,0.83,11506.77,5,6.22,6681.22,4,5.26,10575.41,4,1.91,7477.52,4,0.43,10213.29,4,1.09,709.93,4,5.09,11015.11,4,4.22,88860.06,4,3.57,7079.37,4,1.98,6284.06,4,3.93,10973.56,4,6.18,9917.70,4,0.36,10177.26,4,2.75,3738.76,4,3.33,5643.18,4,5.36,25158.60,
      14459,4.27319,6283.07585,673,3.917,12566.152,77,0.00,0.00,25,3.73,18849.23,4,2.80,6286.60,
      386,2.564,6283.076,31,2.27,12566.15,5,3.44,5573.14,2,2.05,18849.23,1,2.06,77713.77,1,4.41,161000.69,1,3.82,149854.40,1,4.08,6127.66,1,5.26,6438.50,
      9,1.22,6283.08,1,0.66,12566.15}


local function getIntPart(x)
    if x <= 0 then
        return math.ceil(x)
    end

    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x) - 1
    end
    return x
end

function _M.int2(v)
    local value = getIntPart(math.floor(v))
    if value < 0 then
        return value + 1
    else
        return value
    end
end

function _M.XL0_calc(xt,zn,t,n)
    local t = t / 10
    local v = 0
    local tn = 1
    local pn = zn*6 + 1
    --lua下标从1开始
    local N0 = XL00[pn+1 + 1] - XL00[pn + 1]

    local N
    for i = 1,6 do
        local n1 = XL00[pn+i]
        local n2 = XL00[pn+1+i]
        local n0 = n2 - n1
        while true do
            if n0 == 0 then
                break
            end

            if n < 0 then
                N = n2
            else
                N = _M.int2(3*n*n0/(N0-0.0) + 0.5) + n1
                if i > 1 then
                    N = N + 3
                end
                if N > n2 then
                    N = n2
                end
            end
            local c = 0
            for j = n1,N,3 do
                c = c + XL00[j+1] * math.cos(XL00[j+1+1] + t*XL00[j+2+1])
            end

            v = v + c*tn
            tn = tn * t
            break
        end

    end

    local t2,t3
    v = v / XL00[1]
    t2 = t*t
    t3 = t2*t
    v = v + (-0.0728 - 2.7702*t - 1.1019*t2 - 0.0996*t3) / (rad-0.0)
    return v
end


function _M.llrConv(JW,E)
    local r = {}
    local J = JW[1]
    local W = JW[2]
    r[1] = math.atan2(math.sin(J)*math.cos(E) - math.tan(W)*math.sin(E), math.cos(J))
    r[2] = math.asin( math.cos(E)*math.sin(W) + math.sin(E)*math.cos(W)*math.sin(J) )

    r[1]= _M.rad2mrad(r[1])
    return r
end

function _M.mst_ast(t)
    local L = (1753470142 + 628331965331.8*t + 5296.74*t*t)/(1000000000 - 0.0)  + math.pi
    local z = {}
    local E = (84381.4088 -46.836051*t)/rad
    z[1] = _M.XL0_calc(0,0,t,5)+math.pi
    z[2] = 0

    z = _M.llrConv(z,E)
    L = _M.rad2rrad(L - z[1])
    return L/(math.pi * 2)
end

function _M.calc_AST(date,L)
    deltaH = datetime.timedelta(hours=8)
    utcbd = date-deltaH
    bd = JDatetime.JDatetime(utcbd)
    BD = bd.toJD(0)
    JD = bd.toJD(1) - bd.J2000
    BD += mst_ast(JD/36525) + L/(360-0.0)
    bd.setFromJD(BD,0)
    return bd.GetDatetime()
end

return _M







