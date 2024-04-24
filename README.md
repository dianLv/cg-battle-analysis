## 介绍

&emsp;&emsp;在回合制策略卡牌游戏的战斗测试中，面对越来越复杂的战斗逻辑，以及眼花缭乱的战斗表现，传统的测试方法可能无法触及战斗中具体的攻击/受击情况及其来源，对于整场战斗所涉及的个体或全局BUFF变化无法形成清晰的感知，也无法分析伤害/效果的结算顺序及相互关联情况等，往往在问题出现时难以分析与定位错误原因。虽然开发人员也会在代码中添加大量的日志记录，以供后续Debug，但该类日志往往存在大量冗余信息，结构上相对零散，缺乏直观的上下文联系等情况。如果项目经过长期的迭代与人员变动后，会变得难以了解战斗的全貌，以及逻辑间的耦合情况。

&emsp;&emsp;早期很多游戏在战斗表现不足的情况下，会使用文字描述的方式输出战斗信息。这里，参考MMO游戏中《剑灵》的战斗记录功能(攻击/受击信息同步到聊天/战斗中或其他模块)，以较为直白的文字信息进行描述(如skill攻击B, 造成x点伤害；被B的skill击中，受到x点伤害；闪避了B的攻击；陷入濒死状态等)。这使得玩家可以清楚数值，buff结算顺序等信息。对于开发人员和测试人员来说，可以直观看出数值异常和状态变化的错误。所以，模仿这种信息呈现方式并加以改进，将战斗过程转换为一份较为直观的战斗报告，供设计人员、开发人员以及测试人员使用，用来分析战斗过程中涉及的伤害数值、buff、效果执行等情况。

&emsp;&emsp;实际游戏中，可以在战斗的逻辑层到表现层的数据传递上Hook（或者使用回放一类功能的数据），将战斗信息Dump出来并形成结构化的数据（如Lua、JSON、XML等)，再通过解析工具对这些数据进行梳理，形成一份战斗报告。过去也曾经出现过类似的尝试，通过将Battle相关代码fork，并将其中涉及表现相关的内容改造为文本输出。虽然这种方式可以提供与表现层一致的战斗信息，但是需要面对代码变动之“重”，每当Battle代码发生变化时，都需要同时维护fork出来的代码，当需要专门定制一些输出内容时，无法快速响应该类型需求。所以，这里采取的是构建一个专门的战斗结构，该结构与战斗数据保持基本一致，先将战斗数据映射到该结构中，在通过对该结构的解析，以文本形式呈现战斗过程。

## 一、基础结构

* 通常来说，回合制卡牌游戏的基本战斗结构如下，工具也是按类似结构进行分析与输出：

```lua
battle = {
    attacker = {}, -- 攻击者信息
    defender = {}, -- 受击者信息
    battle_type = 0 -- 战斗类型, PVP/PVE/..., 不同类型的胜负结算有差异
    waves = { -- 一场战斗可能会分为1~n波战斗, 通常来说只有1波
        wave = {
            members = { -- 参战成员的信息(如hero, pet, summon, ...), 实际可能会分开, 这里统一成members
                member = {},
                ...
            },
            init_effects = { -- 在完成参战成员的初始化后, 到进入round之前
            },
            rounds = {
                round = { -- 一轮, 包含若干个连续的行动
                    start_round = { -- 一般是进入当前round时
                    },
                    actions = { -- 一系列行动, 如A攻击B, C治疗D, E给F添加buff(放action_effects)等
                        action = { -- attack在该处仅表示一次行动
                            before_action = {},	-- 表示行动前时
                            act_type = 0, -- 行动的类型, 普攻, 技能, 特殊技能等
                            actor = {}, -- 行动者信息, hero, pet, ... 或其他(玩家输入)
                            skill = 0, -- 具体的行动, read skill table
                            action_infos = {}, -- 行动本身产生的damage_info, 伤害/治疗
                            action_effects = {}, -- 受行动影响, 直接产生什么效果(如: 保护, 溅射等)
                            after_action = {}, -- 表示行动后
                            members_update = {} -- 离开当前行动前, 更新成员状态变化(复活, 死亡, ...)
                        },
                        ...
                    },
                    end_round = { -- 表示round结束时执行的效果, 一般是放到action中
                    }
                },
                ...
            }
        },
        ...
    }
}

-- 就一次行动来说, 行动前后的效果, 还涉及行动时的攻击受击情况及衍生, 攻击方还会关联友方单位或全局效果, 受击方可能是一个也可能是多个, 受击者在受击时也会引发其友方单位或全局的效果, 此外buff本身也可能关联到相关的效果与衍生(on_create, on_update)。 
-- 所以, 有大量的回调点(如on_hit, on_miss, on_hurt, on_die, on_kill...), 甚至还会相互拉起
-- 但实际上以具体的行动发起前后来分为before(行动前), during(行动时), after(行动后) 3个阶段
take_effect = {
    target = {}, -- 应用目标
    buffs = {}, -- 表示buff的变化, 可以是add/remove
    effects = {} -- 表示具体效果的(主要是伤害类)
}

-- 由action_infos/effect_infos等伤害类相关的信息
damage_info = {
    target = {}, -- 目标信息
    op = 0, -- 增加或减少
    id = 0, -- 属性id, 用来映射attr(hp, ...)
    value = 0, -- 表现用, A攻击B, 伤害1000, 
    actual_value = 0, -- 但B只有100血或有其他数值影响扣血, 实际产生的值是100, 通过 actual_value
    damage_types = {},  -- 伤害信息, 如暴击, 闪避
}
```

* 补充：自走棋或放置类卡牌的战斗方式，按一定的频率模拟手动操作，数据结构在wave中有所不同，核心是周期性调用的tick(相当于round)，在tick中遍历当前场景中存在的unit的自身逻辑{transform, Status Update, Cast Skill, Settlement Buff Effect...}

```lua
battle = {
    waves = {
        unit_list = {
            self, enemy, ...
        },
        wave = {
            ticks = {
                tick = {
                    tick_index = 0, -- 当前tick
                    operations = {}, -- 当前tick中插入的操作
                    units = {
                        unit.selfTick(),
                    }
                }
            }
        },
    },
    battle_type = {}
}
```

## 二、项目说明

* /reference：一些涉及基本战斗概念的参考
* /src/domain.lua：自定义的战斗结构
* /src/data_convert.lua：将原生的战斗结构，映射到domain中
* /src/stage.lua：模仿原生的战斗表现层，在该场景中对domain进行解析
* /src/mode.lua: 定义游戏规则
* /src/example/*: 一个简单的实现

## 三、参考

* [论卡牌类战斗的实现](https://www.jianshu.com/p/3adca3011184?utm_campaign=haruki&utm_content=note&utm_medium=writer_share&utm_source=weibo)
* [放置回合卡牌构建数值框架与战斗文档设计撰写教学](https://zhuanlan.zhihu.com/p/356189992)
* [用Unity制作一个极具扩展性的顶视角射击游戏战斗系统](https://zhuanlan.zhihu.com/p/416805924)
* [如何实现一个强大的MMO技能系统——BUFF](https://zhuanlan.zhihu.com/p/150812545?utm_id=0)
* [平衡掌控者：游戏数值战斗设计](https://phei.com.cn/module/goods/wssd_content.jsp?bookid=49703)
* [GASDocumentation](https://github.com/tranek/GASDocumentation)
* [从零开始实现放置游戏](https://www.cnblogs.com/lyosaki88/p/idlewow_15.html)

## 四、其他

* 本项目仅供参考
