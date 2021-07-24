import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 初期化されたあとProvider内部のStatefulWidgetで
      // _FizzBuzz インスタンスは保持される
      home: ChangeNotifierProvider(
        create: (BuildContext context) {
          // 引数に渡したValueNotifierなど(ChangeNotifierのサブクラス)の
          // disposeメソッドを適切なタイミングで自動的に呼んでくれるので
          // メモリリークの明示的なケアが不要
          return _FizzBuzz();
        },
        // setStateはProviderの内部で呼ばれているため、child引数として外から渡された
        // _HomePage は使い回されるので const 指定の有無に関わらず
        // 巻き込まれビルドのようなことは起こらずに済む
        child: const _HomePage(),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('main_fizz_buzz_provider'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () =>
            Provider.of<_FizzBuzz>(
              context,
              listen: false, // 監視は抑制した方がパフォーマンス的にベター
            ).increment(),
      ),
      body: Center(
        child: const _Message(),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('_Message: rebuild');
    return Text(
      'Message: ${Provider.of<_FizzBuzz>(context).message}', // 表示メッセージを監視
      style: TextStyle(fontSize: 64),
    );
  }
}

class _FizzBuzz extends ValueNotifier<int> {
  _FizzBuzz() : super(1);
  // setStateが呼ばれている箇所が消えたが、それはValueNotifierのvalueが変更されると
  // 内部的にnotifyListeners()が呼ばれて、それをChangeNotifierProviderが検知して
  // Provider.ofで監視しているWidgetに伝えて(内部のStateでsetStateして)リビルドされるため
  void increment() => value++;

  String get message {
    final result = value % 15 == 0
        ? 'FizzBuzz'
        : (value % 3 == 0 ? 'Fizz' : (value % 5 == 0 ? 'Buzz' : '-'));
    print('value: $value, result: $result');
    return result;
  }
}
