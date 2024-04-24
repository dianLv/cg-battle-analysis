-- 一个参考的原始数据
return {
  ["self_name"] = '甲方',
  ["oppo_name"] = '乙方',
  ["waves"] = {
    [1] = {
      ["wave_index"] = 1,
      ["members"] = {
        [1] = {
          ["camp"] = 1,
          ["pos"] = 1,
          ["hp"] = 1000,
          ["max_hp"] = 1000,
          ["alive"] = true,
          ["energy"] = 2,
          ["id"] = 1001,
          ["member_type"] = 1
        },
        [2] = {
          ["camp"] = 1,
          ["pos"] = 2,
          ["hp"] = 1000,
          ["max_hp"] = 1000,
          ["alive"] = true,
          ["energy"] = 2,
          ["id"] = 1002,
          ["member_type"] = 1
        },
        [3] = {
          ["camp"] = 1,
          ["pos"] = 3,
          ["hp"] = 1000,
          ["max_hp"] = 1000,
          ["alive"] = true,
          ["energy"] = 2,
          ["id"] = 1003,
          ["member_type"] = 1
        },
        [4] = {
          ["camp"] = 2,
          ["pos"] = 1,
          ["hp"] = 1000,
          ["max_hp"] = 1000,
          ["alive"] = true,
          ["energy"] = 2,
          ["id"] = 1001,
          ["member_type"] = 1
        },
        [5] = {
          ["camp"] = 2,
          ["pos"] = 2,
          ["hp"] = 1000,
          ["max_hp"] = 1000,
          ["alive"] = true,
          ["energy"] = 2,
          ["id"] = 1002,
          ["member_type"] = 1
        },
        [6] = {
          ["camp"] = 2,
          ["pos"] = 3,
          ["hp"] = 1000,
          ["max_hp"] = 1000,
          ["alive"] = true,
          ["energy"] = 2,
          ["id"] = 1003,
          ["member_type"] = 1
        },
      },
      ["init_effects"] = {
        [1] = {
          ["target"] = {
            ["camp"] = 1,
            ["type"] = 1,
            ["pos"] = 1
          },
          ["effects"] = {
            ["skill_id"] = 0,
            ["buff_id"] = 10000,
            ["effect_infos"] = {
              [1] = {
                ["target"] = {
                  ["camp"] = 1,
                  ["type"] = 1,
                  ["pos"] = 1
                },
                ["id"] = 3,
                ["op"] = 1,
                ["value"] = 0,
                ["actual_value"] = 2,
                ["effect_id"] = 0
              }
            }
          },
          ["buffs"] = {
            [1] = {
              ["id"] = 1,
              ["buff_id"] = 10000,
              ["skill_id"] = 0,
              ["op"] = 1,
              ["round"] = 99,
              ["num"] = 1,
              ["caster"] = {
                ["camp"] = 1,
                ["type"] = 1,
                ["pos"] = 1
              }
            },
            [2] = {
              ["id"] = 2,
              ["buff_id"] = 10001,
              ["skill_id"] = 0,
              ["op"] = 1,
              ["round"] = 99,
              ["num"] = 1,
              ["caster"] = {
                ["camp"] = 1,
                ["type"] = 1,
                ["pos"] = 1,
              }
            }
          }
        },
        [2] = {
          ["target"] = {
            ["camp"] = 2,
            ["type"] = 1,
            ["pos"] = 1
          },
          ["effects"] = {},
          ["buffs"] = {
            [1] = {
              ["id"] = 3,
              ["buff_id"] = 10001,
              ["skill_id"] = 0,
              ["op"] = 1,
              ["round"] = 99,
              ["num"] = 1,
              ["caster"] = {
                ["camp"] = 2,
                ["type"] = 1,
                ["pos"] = 1,
              }
            }
          }
        }
      },
      ["order"] = 1,
      ["rounds"] = {
        [1] = {
          ["round_index"] = 1,
          ["before_round_effects"] = {
          },
          ["actions"] = {
            [1] = {
              ["action_type"] = 0,
              ["actor_info"] = {
                ["camp"] = 1,
                ["pos"] = 1,
                ["type"] = 1
              },
              ["skill_id"] = 1000,
              ["action_infos"] = {
                [1] = {
                  ["target"] = {
                    ["camp"] = 2,
                    ["pos"] = 1,
                    ["type"] = 1
                  },
                  ["id"] = 1,
                  ["value"] = 1000,
                  ["actual_value"] = 500,
                  ["op"] = 2,
                  ["action_types"] = {
                    [1] = {
                      ["type"] = 1,
                      ["value"] = 0
                    }
                  }
                },
                [2] = {
                  ["target"] = {
                    ["camp"] = 2,
                    ["pos"] = 2,
                    ["type"] = 1
                  },
                  ["id"] = 1,
                  ["value"] = 1000,
                  ["actual_value"] = 400,
                  ["op"] = 2,
                  ["action_types"] = {
                    [1] = {
                      ["type"] = 1,
                      ["value"] = 0
                    },
                    [2] = {
                      ["type"] = 3,
                      ["value"] = 0
                    }
                  }
                },
                [3] = {
                  ["target"] = {
                    ["camp"] = 2,
                    ["pos"] = 3,
                    ["type"] = 1
                  },
                  ["id"] = 1,
                  ["value"] = 0,
                  ["actual_value"] = 0,
                  ["op"] = 2,
                  ["action_types"] = {
                    [1] = {
                      ["type"] = 2,
                      ["value"] = 0
                    }
                  }
                }
              },
              ["action_effects"] = {
                [1] = {
                  ["target"] = {
                    ["camp"] = 1,
                    ["type"] = 1,
                    ["pos"] = 1
                  },
                  ["effects"] = {
                    ["skill_id"] = 0,
                    ["buff_id"] = 20000,
                    ["effect_infos"] = {
                      [1] = {
                        ["target"] = {
                          ["camp"] = 1,
                          ["type"] = 1,
                          ["pos"] = 1
                        },
                        ["id"] = 3,
                        ["op"] = 2,
                        ["value"] = 0,
                        ["actual_value"] = 4,
                        ["effect_id"] = 0
                      }
                    }
                  }
                }
              }
            },
            [2] = {
              ["action_type"] = 0,
              ["actor_info"] = {
                ["camp"] = 2,
                ["pos"] = 1,
                ["type"] = 1
              },
              ["skill_id"] = 1001,
              ["action_infos"] = {
                [1] = {
                  ["target"] = {
                    ["camp"] = 1,
                    ["pos"] = 1,
                    ["type"] = 1
                  },
                  ["id"] = 1,
                  ["value"] = 100,
                  ["actual_value"] = 100,
                  ["op"] = 2
                }
              },
              ["action_effects"] = {
                [1] = {
                  ["target"] = {
                    ["camp"] = 2,
                    ["type"] = 1,
                    ["pos"] = 1
                  },
                  ["effects"] = {
                    ["skill_id"] = 0,
                    ["buff_id"] = 20001,
                    ["effect_infos"] = {
                      [1] = {
                        ["target"] = {
                          ["camp"] = 2,
                          ["type"] = 1,
                          ["pos"] = 1
                        },
                        ["id"] = 3,
                        ["op"] = 1,
                        ["value"] = 0,
                        ["actual_value"] = 2,
                        ["effect_id"] = 0
                      }
                    }
                  }
                }
              }
            },
          }
        }
      },
      ["members_final"] = {
      },
      ["is_win"] = true
    }
  },
  ["is_win"] = true,
  ["type"] = 2,
  ["version"] = '0.0.0.0'
}