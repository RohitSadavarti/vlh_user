import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/printer_device.dart';
import '../services/printer_service.dart';

class PrinterSetupScreen extends StatefulWidget {
  const PrinterSetupScreen({super.key});

  @override
  State<PrinterSetupScreen> createState() => _PrinterSetupScreenState();
}

class _PrinterSetupScreenState extends State<PrinterSetupScreen> {
  List<PrinterDevice> _availableDevices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
  }

  Future<void> _loadDevices() async {
    if (_isScanning) return;
    
    setState(() => _isScanning = true);
    
    final printerService = Provider.of<PrinterService>(context, listen: false);
    final devices = await printerService.getAvailableDevices();
    
    if (mounted) {
      setState(() {
        _availableDevices = devices;
        _isScanning = false;
      });
      
      if (printerService.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(printerService.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectDevice(PrinterDevice device) async {
    final printerService = Provider.of<PrinterService>(context, listen: false);
    
    final success = await printerService.connectToDevice(device);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(printerService.errorMessage ?? 'Connection failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testPrint() async {
    final printerService = Provider.of<PrinterService>(context, listen: false);
    final success = await printerService.testPrint();
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test print sent!'), backgroundColor: Colors.blue),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(printerService.errorMessage ?? 'Print failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E3A8A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Printer Settings',
          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _loadDevices,
          ),
        ],
      ),
      body: Consumer<PrinterService>(
        builder: (context, printerService, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Current Connection Status
              _buildStatusCard(printerService, primaryColor),
              
              const SizedBox(height: 32),
              
              // Device List Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Devices',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isScanning)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_availableDevices.isEmpty && !_isScanning)
                _buildEmptyState()
              else
                ..._availableDevices.map((device) => _buildDeviceTile(device, printerService, primaryColor)),
                
              const SizedBox(height: 40),
              
              // Instructions
              _buildInstructions(primaryColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(PrinterService printerService, Color primaryColor) {
    final isConnected = printerService.isConnected;
    final printer = printerService.connectedPrinter;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isConnected ? Colors.green.shade200 : Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.print_disabled,
                color: isConnected ? Colors.green : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                isConnected ? 'Printer Connected' : 'No Printer Connected',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.green.shade800 : Colors.blue.shade800,
                ),
              ),
            ],
          ),
          if (printer != null) ...[
            const SizedBox(height: 12),
            Text(
              'Device: ${printer.name}',
              style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              'Address: ${printer.address}',
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testPrint,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Test Print'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => printerService.disconnectPrinter(),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => printerService.clearSavedPrinter(),
                child: const Text('Forget Device', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceTile(PrinterDevice device, PrinterService printerService, Color primaryColor) {
    final isConnecting = printerService.isConnecting;
    final isConnected = printerService.connectedPrinter?.address == device.address && printerService.isConnected;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isConnected ? Colors.green.shade100 : Colors.blue.shade100,
          child: Icon(Icons.print, color: isConnected ? Colors.green : Colors.blue),
        ),
        title: Text(
          device.name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(device.address),
        trailing: isConnected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (isConnecting && printerService.errorMessage == null)
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: isConnected || isConnecting ? null : () => _connectDevice(device),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No printers found',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your printer is in pairing mode and Bluetooth is on.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadDevices,
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Troubleshooting',
          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _bulletPoint('Ensure the printer is 58mm Thermal ESC/POS compatible.'),
        _bulletPoint('Turn the printer OFF and ON again.'),
        _bulletPoint('Go to Phone Bluetooth Settings and unpair/re-pair the printer.'),
        _bulletPoint('Grant Location and Bluetooth permissions if prompted.'),
      ],
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey.shade700))),
        ],
      ),
    );
  }
}
