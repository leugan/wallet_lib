import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../../core/services/wallet_storage_service.dart';
import '../../../core/config/chain_config.dart';
import '../../../core/theme/app_theme.dart';

class BalanceCard extends StatefulWidget {
  final String address;
  final String chainType;
  final bool useDarkStyle;
  // 添加总资产价值参数
  final double totalUsdValue;

  const BalanceCard({
    Key? key,
    required this.address,
    required this.chainType,
    this.useDarkStyle = false,
    this.totalUsdValue = 0.0,
  }) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final WalletStorageService _storageService = WalletStorageService();

  bool _isLoading = true;
  String _walletName = ''; // 钱包名称

  @override
  void initState() {
    super.initState();
    _loadWalletName();
  }

  @override
  void didUpdateWidget(BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address ||
        oldWidget.chainType != widget.chainType) {
      _loadWalletName();
    }
  }

  Future<void> _loadWalletName() async {
    if (!mounted) return; // 添加检查，如果组件已卸载则直接返回
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取钱包信息
      final wallet = await _storageService.getWalletByAddress(widget.address);

      // 添加mounted检查
      if (mounted) {
        setState(() {
          _walletName = wallet?.name ?? '我的钱包';
          _isLoading = false;
        });
      }
    } catch (e) {
      dev.log('加载钱包名称失败: $e', name: 'BalanceCard');
      // 添加mounted检查
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chainConfig = ChainConfigs.getChainConfig(widget.chainType);
    // 使用主题颜色而不是硬编码颜色
    final textColor = widget.useDarkStyle 
        ? Colors.white 
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final cardTheme = AppTheme.getTheme().cardTheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: cardTheme.color,
      // 使用主题定义的卡片形状
      shape: cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 链名称和钱包名称
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chainConfig.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _walletName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 地址
            Text(
              widget.address.length > 20
                  ? '${widget.address.substring(0, 10)}...${widget.address.substring(widget.address.length - 10)}'
                  : widget.address,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            // 总资产价值
            Center(
              child: Column(
                children: [
                  _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        )
                      : Text(
                          '\$${widget.totalUsdValue.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
