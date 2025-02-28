<template>
  <div id="alternativa-imagem-x">
    <div class="palavra-items">
      <div class="row">
        <div class="col-md-7">
          <div
            class="items-input-group select-multiple incorrect-items-input-group"
          >
            <div class="label">
              <div>Alternativas Erradas:</div>
              <div>(3 items)</div>
            </div>
            <v-select
              v-model="sentences"
              @input="addItem"
              :searchable="isSearchable"
              multiple
              taggable
              label="word_text"
            >
              <span slot="no-options">
                {{ searchFeedback }}
              </span>
            </v-select>
          </div>
        </div>
        <div class="col-md-5"></div>
      </div>
    </div>
    <div class="row">
      <div class="col-md-7">
        <ls-modal-create-word
          ref="embedded"
          :embedded="true"
          :word-type="word_type"
          :text="initialPalavra"
          :is-editing="isEditing"
          :word-id="word_id"
          :word-type-disabled="true"
          :audio-required="false"
          :image-required="true"
          :audio-visible="false"
          :image-visible="true"
          :wordTypeVisible="false"
          :label-text="'Alternativa Correta: (Item)'"
        />
      </div>
      <div class="col-md-5"></div>
    </div>
    <div v-if="isEditing" class="actions">
      <a tag="button" class="btn btn-default" :href="backUrl" :disabled="busy"
        >Cancelar
      </a>
      <button
        @click="submit"
        class="btn btn-primary"
        :disabled="busy || !hasDescription"
      >
        Editar Atividade
      </button>
    </div>
    <div v-else class="actions">
      <router-link
        tag="button"
        class="btn btn-default"
        :to="{ name: 'templates' }"
        :disabled="busy"
        >Cancelar</router-link
      >
      <button
        @click="submit"
        class="btn btn-primary"
        :disabled="busy || !hasDescription"
      >
        Criar Atividade
      </button>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import TemplateMixin from '../../mixins/TemplateMixin'
import Item from '../../models/Item'
import { WordTypes } from '../../types'

export default {
  mixins: [TemplateMixin],
  data() {
    return {
      busy: false,
      word_type: WordTypes.input_custom.value,
      items: [],
      sentences: [],
      clonedItem: [],
      incorrectsItems: [],
      validate: true,
      initialPalavra: ''
    }
  },
  created() {
    if (this.isEditing) {
      this.initialPalavra = this.theKey.text
      this.sentences = this.generateInputValues.map(el => {
        return el.text
      })
      this.addItem(this.sentences)
    }
  },
  computed: {
    searchFeedback() {
      return this.isSearchable
        ? 'Digite uma frase para continuar...'
        : 'Limite máximo de frases foi atigindo.'
    },
    isSearchable() {
      return this.sentences.length < this.maxItems
    },
    isSubmitDisabled() {
      return this.$parent.hasDescription && this.items.length >= 3
    },
    backUrl() {
      const { id } = this.$route.params
      return `/question/questions/${id}`
    },
    word_id() {
      if (this.theKey) {
        return this.theKey.word_id
      }
      return null
    }
  },
  methods: {
    addItem(alternatives) {
      const incorrects = alternatives.map(text => {
        return new Item('value', this.WordTypes.input_custom.key, text)
      })
      this.incorrectsItems = incorrects
      this.clonedItem = this.items = [
        ...this.items.filter(({ type }) => type === 'key'),
        ...incorrects
      ]
    },
    async submit() {
      try {
        this.busy = true
        // Aguardando nova palavra ser criada
        const { data } = await this.$refs.embedded.submit()

        const items = []

        const word = data.text ? data.text : this.initialPalavra

        const value_items_attributes = [
          new Item('value', this.WordTypes.input_custom.value, word)
        ]

        items.push(
          new Item(
            'key',
            WordTypes.input_custom.value,
            word,
            null,
            value_items_attributes
          )
        )
        const newItems = items.concat(this.incorrectsItems)
        Vue.set(this, 'items', newItems)

        // Salvando no banco novo template de questão
        setTimeout(() => {
          this.$emit('submitTemplate')
        }, 1000)
      } catch (e) {
        this.$notify({
          group: 'danger',
          title: 'Falha',
          text: e.message
        })

        this.busy = false
      }
    }
  },
  mounted() {
    this.$emit('defaultActionsVisibilty', false)
  }
}
</script>

<style lang="scss">
#alternativa-imagem-x {
  .actions {
    .btn:first-child {
      margin-right: 5px;
    }
  }

  .form-group {
    display: flex;
    align-items: center;
    padding: ($gap * 2) 0px;
    margin-bottom: 0px;
    label {
      flex: 1;
    }
    .form-control {
      text-indent: 12px;
      padding: 0px;
      flex: 3;
    }
  }

  .correct-items,
  .incorrect-items {
    @include template-editor-field;
    margin: $gap 0px;
    &-input-group {
      .v-select {
        flex: 3;
      }
    }
  }
}
</style>
