{% import 'utils.cl' as utils %}

{% macro smi_push(program, op) -%}
/**
 * @brief private function SMI_Push push a data elements in the transient channel. Data transferring can be delayed
 * @param chan
 * @param data
 * @param immediate: if true the data is immediately sent, without waiting for the completion of the network packet.
 *          In general, the user should use the athore Push definition
 */
void {{ utils.impl_name_port_type("SMI_Push_flush", op) }}(SMI_Channel *chan, void* data, int immediate)
{
    char* conv = (char*) data;
    COPY_DATA_TO_NET_MESSAGE(chan, chan->net, conv);
    chan->processed_elements++;
    chan->packet_element_id++;
    chan->tokens--;

    {% set cks_data = program.create_group("cks_data") %}
    {% set ckr_control = program.create_group("ckr_control") %}
    // send the network packet if it full or we reached the message size
    if (chan->packet_element_id == chan->elements_per_packet || immediate || chan->processed_elements == chan->message_size)
    {
        SET_HEADER_NUM_ELEMS(chan->net.header, chan->packet_element_id);
        chan->packet_element_id = 0;
        write_channel_intel({{ utils.channel_array("cks_data") }}[{{ cks_data.get_hw_port(op.logical_port) }}], chan->net);
    }
    // This fence is not mandatory, the two channel operations can be
    // performed independently
    // mem_fence(CLK_CHANNEL_MEM_FENCE);

    if (chan->tokens == 0)
    {
        // receives also with tokens=0
        // wait until the message arrives
        SMI_Network_message mess = read_channel_intel({{ utils.channel_array("ckr_control") }}[{{ ckr_control.get_hw_port(op.logical_port) }}]);
        unsigned int tokens = *(unsigned int *) mess.data;
        chan->tokens += tokens; // tokens
    }
}

/**
 * @brief SMI_Push push a data elements in the transient channel. The actual ata transferring can be delayed
 * @param chan pointer to the channel descriptor of the transient channel
 * @param data pointer to the data that can be sent
 */
void {{ utils.impl_name_port_type("SMI_Push", op) }}(SMI_Channel *chan, void* data)
{
    {{ utils.impl_name_port_type("SMI_Push_flush", op) }}(chan, data, 0);
}
{% endmacro %}