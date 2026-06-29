import 'package:flutter/material.dart';



class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            // Large screen
            return _buildWideContainers();
          } else if (constraints.maxWidth > 800 && constraints.maxWidth <= 1200) {
            // Medium screen
            return _buildMediumContainers();
          } else {
            // Small screen
            return _buildNarrowContainers();
          }
        },
    );
  }

  Widget _buildWideContainers() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.blue[100],
            child: Column(
              children: [
                _buildHeader(),
                _buildContent(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.blue[200],
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMediumContainers() {
    return Column(
      children: [
        Container(
          height: 100,
          color: Colors.blue[100],
          child: _buildHeader(),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue[200],
                  child: _buildContent(),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.blue[300],
                  child: _buildMainContent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowContainers() {
    return Column(
      children: [
        Container(
          height: 100,
          color: Colors.blue[100],
          child: _buildHeader(),
        ),
        Expanded(
          child: Container(
            color: Colors.blue[200],
            child: _buildMainContent(),
          ),
        ),
        Container(
          height: 200,
          color: Colors.blue[300],
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Text(
        'Header',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildContent() {
    return const Center(
      child: Text(
        'Content',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildMainContent() {
    return const Center(
      child: Text(
        'Main Content',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}