<template>
  <div id="app">
    <div class="container">
      <section class="section has-text-centered">
        <h1 class="title">DJI SRT Filter</h1>

        <div class="notification">
          <b-field
            class="file is-primary is-centered"
            :class="{ 'has-name': !!file }"
          >
            <b-upload v-model="file" @input="onInput" class="file-label">
              <span class="file-cta">
                <span class="file-label">Click to upload</span>
              </span>
              <span class="file-name" v-if="file">
                {{ file.name }}
              </span>
            </b-upload>
          </b-field>

          <div v-if="file">
            <div class="columns">
              <div class="column">
                <span class="subtitle">Disabled</span>
                <draggable class="list-group" :list="disabled" group="stats">
                  <div v-for="stat in disabled" :key="stat.name">
                    <b-button class="is-fullwidth mb-1">
                      {{ stat.label }}
                    </b-button>
                  </div>
                </draggable>
              </div>

              <div class="column">
                <span class="subtitle">Enabled</span>
                <draggable class="list-group" :list="enabled" group="stats">
                  <div v-for="stat in enabled" :key="stat.name">
                    <b-button class="is-fullwidth mb-1">
                      {{ stat.label }}
                    </b-button>
                  </div>
                </draggable>
              </div>
            </div>

            <b-button type="is-success" @click="save">Save</b-button>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import { find, each, map } from "lodash";
import { parseSync, stringifySync } from "subtitle";
import draggable from "vuedraggable";
import { saveAs } from "file-saver";

export default {
  name: "App",
  metaInfo: {
    title: "DJI SRT Filter",
  },
  components: {
    draggable,
  },
  computed: {
    currentStatObj() {
      return find(this.stats, { name: this.currentStat });
    },
  },
  data() {
    return {
      file: null,
      points: [],
      enabled: [
        {
          name: "delay",
          label: "Delay",
        },
        {
          name: "bitrate",
          label: "Bitrate",
        },
        {
          name: "glsBat",
          label: "Goggles Battery",
        },
        {
          name: "rcSignal",
          label: "RC Signal",
        },
        {
          name: "uavBat",
          label: "Drone Battery",
        },
      ],
      disabled: [
        {
          name: "signal",
          label: "Signal",
        },
        {
          name: "ch",
          label: "Channel",
        },
      ],
    };
  },
  methods: {
    async onInput(file) {
      this.file = file;

      const fileText = await file.text();
      const subtitles = parseSync(fileText);

      const points = map(subtitles, (subtitle) => {
        const stats = subtitle.data.text.split(" ");
        const statsObj = {};

        each(stats, (stat) => {
          const [statName] = stat.split(":");
          statsObj[statName] = stat;
        });

        return {
          ...subtitle,
          parsed: statsObj,
        };
      });

      this.points = points;
    },
    save() {
      const points = map(this.points, (point) => {
        const statStrings = map(this.enabled, (enabledStat) => {
          const stSz = point.parsed[enabledStat.name];

          return stSz;
        });

        const newPoint = { ...point };
        newPoint.data.text = statStrings.join(" ");
        delete newPoint.parsed;

        return newPoint;
      });

      console.log("bird");

      const outputFileSz = stringifySync(points, {});

      const nameWithoutExt = this.file.name.replace(".srt", "");
      const file = new File([outputFileSz], `${nameWithoutExt}-filtered.srt`, {
        type: "text/plain;charset=utf-8",
      });

      saveAs(file);
    },
  },
};
</script>
