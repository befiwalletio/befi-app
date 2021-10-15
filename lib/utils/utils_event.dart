import 'package:cube/models/model_base.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class ECurrency {}

class UpdateChain{}

class UpdateWallet{}

class UpdateIdentity{
  Identity identity;

  UpdateIdentity(this.identity);
}

class CloseDrawer{}

class UpdateNft{}

class UpdateDownProgress{
  double progress;
}