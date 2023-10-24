import { BodyHandle } from "engine/BodyHandle";
import { LMent } from "engine/LMent";
import { GameplayScene } from "engine/GameplayScene";
import { HitPointChangeHandler } from "engine/MessageHandlers";

export class DestroyOnZeroHP extends LMent implements HitPointChangeHandler
{
  private destroyed: boolean;
  destructionDelay: number;

  constructor(body: BodyHandle, params: Partial<DestroyOnZeroHP> = {})
  {
    super(body);
    this.destroyed = false;
    this.destructionDelay = params.destructionDelay === undefined? 0 : params.destructionDelay;
  }

  onInit(): void {
    GameplayScene.instance.dispatcher.addListener("hitPointsChanged", this);
  }

  onStart(): void {
    
  }

  doDestroy()
  {
    GameplayScene.instance.destroyBody(this.body);
  }

  onHitPointChange(source: BodyHandle, previousHP: number, currentHP: number): void {
    if (source == this.body && currentHP <= 0 && !this.destroyed)
    {
      if (this.destructionDelay <= 0)
      {
        this.doDestroy();
      }
      else
      {
        GameplayScene.instance.dispatcher.queueDelayedFunction(undefined, this.doDestroy.bind(this), this.destructionDelay);
      }
      this.destroyed = true;
    }
  }
}