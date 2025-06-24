import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pomodoro/provider/pomodoro_provider.dart';
import 'package:provider/provider.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        final dailyFocusSeconds = provider.getTotalFocusTimeForDay(DateTime.now());
        final dailyFocusMinutes = dailyFocusSeconds ~/ 60;
        final dailyFocusHours = dailyFocusMinutes ~/ 60;
        final remainingMinutes = dailyFocusMinutes % 60;
        
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Focus Time',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$dailyFocusHours hrs $remainingMinutes mins',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Weekly Focus Time',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
                  child: _buildWeeklyChart(context, provider),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Monthly Focus Time',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
                  child: _buildMonthlyChart(context, provider),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildWeeklyChart(BuildContext context, PomodoroProvider provider) {
    final weeklyData = provider.getWeeklyFocusTime();
    // Set a constant maximum Y value (in minutes) for the weekly chart
    // 360 minutes = 6 hours as maximum scale
    const double maxYValue = 360;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxYValue,
        barGroups: weeklyData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key.weekday,
            barRods: [
              BarChartRodData(
                toY: (entry.value / 60).toDouble(), // Convert seconds to minutes
                color: Colors.lightGreen,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const weekdayNames = ['','Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value >= 1 && value <= 7) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weekdayNames[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Show hourly intervals (60, 120, 180, 240 minutes)
                if (value % 60 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${(value / 60).toInt()}h',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          horizontalInterval: 60, // 1 hour intervals
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[350],
              strokeWidth: .7,
            );
          },
        ),
      ),
    );
  }
//====================================================================================
 
  Widget _buildMonthlyChart(BuildContext context, PomodoroProvider provider) {
    final monthlyData = provider.getMonthlyFocusTime();
    const double maxYValue = 100;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxYValue,
        barGroups: monthlyData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key.month, // Month number (1-12)
            barRods: [
              BarChartRodData(
                toY: (entry.value / 60 / 60).toDouble(), // Convert seconds to hours
                color: Colors.lightBlue,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (value >= 1 && value <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      monthNames[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 10 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      '${value.toInt()}h',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[350],
              strokeWidth: .7,
            );
          },
        ),
      ),
    );
  }
}
