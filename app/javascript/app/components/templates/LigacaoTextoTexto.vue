<template>
  <div id="ligacao-texto-texto">
    <div class="type">
      <div class="row">
        <div class="col-md-7">
          <div class="type-input-group">
            <label class="label">Tipo</label>
            <span class="input">
              <v-select
                v-model="word_type"
                :filterable="false"
                :options="types"
                label="label"
                placeholder="Selecionar"
              />
            </span>
          </div>
        </div>
        <div class="col-md-5"></div>
      </div>
    </div>
    <div class="alternativa-items">
      <div class="row">
        <div class="col-md-7">
          <ls-select-multiple
            ref="select"
            class="alternativa-items-input-group"
            :word-type="type"
            :options="words"
            :max-items="maxItems"
            :searchable="this.items.length < 5"
            :label="'Lista de Palavras:'"
            :initial-items="initialItems"
            @search="onSearch"
            @search:focus="clear"
            @input="addItem"
          />
          <div>(2 à 5 items)</div>
        </div>
        <div class="col-md-5"></div>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import { values } from 'lodash'
import Item from '../../models/Item'
import TemplateMixin from '../../mixins/TemplateMixin'
import { WordTypes } from '../../types'

const templateTypes = [
  WordTypes.substantivo_comum.value,
  WordTypes.substantivo_proprio.value
]

export default {
  mixins: [TemplateMixin],
  data() {
    return {
      items: [],
      cloneItems: [],
      initialItems: [],
      word_type: WordTypes.substantivo_comum
    }
  },
  computed: {
    types() {
      return values(WordTypes).filter(t => templateTypes.includes(t.value))
    }
  },
  created() {
    if (this.isEditing) {
      this.initialItems = this.generateInputKeys
      this.addItem(this.initialItems)
    }
  },
  methods: {
    addItem(alternatives) {
      const items = alternatives.map(({ text }) => {
        const letter = text[0]
        const value_items_attributes = [
          new Item('value', this.WordTypes.letra.value, letter)
        ]
        return new Item(
          'key',
          this.WordTypes.substantivo_comum.value,
          text,
          null,
          value_items_attributes
        )
      })

      Vue.set(this, 'items', items)
    },
    validateItems() {
      this.$emit('validateItems', this.items.length >= 2)
    },
    emptyList() {}
  },
  watch: {
    type(t) {
      if (this.$refs.select && !this.initialItems.length > 0) {
        this.$refs.select.clearSelection()
      }
      this.items = []
      this.initialItems = []
    }
  }
}
</script>

<style lang="scss">
#ligacao-texto-texto {
  .alternativa-items,
  .type {
    @include template-editor-field;
    margin: $gap 0px;
  }
}
</style>
