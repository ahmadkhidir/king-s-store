import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/components/prompt_field.dart';
import 'package:sales_ai_examples/src/components/voice_text_tile.dart';
import 'package:sales_ai_examples/src/products/bloc/products_bloc.dart';
import 'package:sales_ai_examples/src/products/screens/cart_screen.dart';
import 'package:sales_ai_examples/src/products/screens/checkout_screen.dart';
import 'package:sales_ai_examples/src/sales_ai/bloc/sales_ai_bloc.dart';
import 'package:sales_ai_examples/src/sales_ai/utils/models.dart';

class ErrorDialog extends StatelessWidget {
  final String statusMessage;
  final void Function()? onPressed;
  const ErrorDialog({
    super.key,
    required this.statusMessage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(statusMessage),
      actions: [
        TextButton(
          onPressed: onPressed,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class PromptModal extends StatefulWidget {
  const PromptModal({super.key});

  @override
  State<PromptModal> createState() => _PromptModalState();
}

class _PromptModalState extends State<PromptModal> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollToBottom();
    });
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesAiBloc, SalesAiState>(
      listener: (context, state) {
        for (var element in state.commands) {
          switch (element.type) {
            case "add-to-cart":
              context.read<ProductsBloc>().add(AddCartItemByID(element.value));
              break;
            case "remove-from-cart":
              context.read<ProductsBloc>().add(RemoveCartItemByID(element.value));
              break;
            case "view-cart":
              context.goNamed(CartScreen.routeName);
              break;
            case "checkout":
              context.read<ProductsBloc>().add(AddCartItemByID(element.value));
              context.goNamed(CheckoutScreen.routeName);
            default:
              debugPrint("Unknown command: ${element.type}");
          }
          context.read<SalesAiBloc>().add(DeleteAICommand(element.key));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<SalesAiBloc, SalesAiState>(
              builder: (context, state) {
                if (state.status == SalesAIStatus.loading) {
                  return const LinearProgressIndicator();
                } else if (state.status == SalesAIStatus.error) {
                  return Text(
                    "Error: ${state.statusMessage}",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox();
              },
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: BlocBuilder<SalesAiBloc, SalesAiState>(
                  buildWhen: (previous, current) {
                    scrollToBottom();
                    return true;
                  },
                  builder: (context, state) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: state.chats.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Adem is here to help you!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Powered by Gemini",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < state.chats.length; i++)
                                  VoiceTextTile(
                                    state.chats[i].message,
                                    subtitle: state.chats[i].sender == Sender.ai
                                        ? 'Adem'
                                        : 'You',
                                    voiceActive:
                                        state.chats[i].sender == Sender.ai,
                                    // 1 min lag and the last AI response
                                    autoVoiceActive:
                                        state.chats[i].sender == Sender.ai &&
                                            i == state.chats.length - 1 &&
                                            state.chats[i].time
                                                .add(const Duration(minutes: 1))
                                                .isAfter(DateTime.now()),
                                    titleAlign:
                                        state.chats[i].sender == Sender.ai
                                            ? WrapAlignment.start
                                            : WrapAlignment.end,
                                    subtitleAlign:
                                        state.chats[i].sender == Sender.ai
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                  ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
            const PromptField(),
          ],
        ),
      ),
    );
  }
}

